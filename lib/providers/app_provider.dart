import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/application.dart';
import '../models/invite.dart';
import '../models/job.dart';
import '../models/review.dart';

class AppProvider extends ChangeNotifier {
  static const String _storageKey = 'trabahotap_data';

  List<AppUser> users = [];
  List<Job> jobs = [];
  List<Application> applications = [];
  List<Review> reviews = [];
  List<Invite> invites = [];
  String? currentUserId;
  bool hasSeenOnboarding = false;
  bool isLoaded = false;

  AppUser? get currentUser {
    if (currentUserId == null) return null;
    for (final u in users) {
      if (u.id == currentUserId) return u;
    }
    return null;
  }

  double averageRating(String userId) {
    final userReviews = reviews.where((r) => r.toUserId == userId).toList();
    if (userReviews.isEmpty) return 0;
    final total = userReviews.fold<int>(0, (sum, r) => sum + r.stars);
    return total / userReviews.length;
  }

  int reviewCount(String userId) {
    return reviews.where((r) => r.toUserId == userId).length;
  }

  List<Review> reviewsFor(String userId) {
    final list = reviews.where((r) => r.toUserId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  bool hasReviewed(String fromUserId, String toUserId, String jobId) {
    return reviews.any(
      (r) =>
          r.fromUserId == fromUserId &&
          r.toUserId == toUserId &&
          r.jobId == jobId,
    );
  }

  AppUser? userById(String id) {
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  AppUser? employerFor(Job job) {
    return userById(job.employerId);
  }

  Job? jobById(String jobId) {
    for (final j in jobs) {
      if (j.id == jobId) return j;
    }
    return null;
  }

  String jobTitle(String jobId) {
    return jobById(jobId)?.title ?? 'Deleted job';
  }

  bool hasApplied(String seekerId, String jobId) {
    return applications.any(
      (a) => a.seekerId == seekerId && a.jobId == jobId,
    );
  }

  // Number of workers already hired for a job.
  int hiredCount(String jobId) {
    return applications
        .where((a) => a.jobId == jobId && a.status == ApplicationStatus.hired)
        .length;
  }

  List<Application> applicationsForSeeker(String seekerId) {
    return applications.where((a) => a.seekerId == seekerId).toList().reversed.toList();
  }

  Future<bool> applyToJob(String seekerId, String jobId) async {
    final job = jobById(jobId);
    if (job == null || job.isFull) return false;
    if (hasApplied(seekerId, jobId)) return false;
    final app = Application(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jobId: jobId,
      seekerId: seekerId,
      status: ApplicationStatus.pending,
    );
    applications.add(app);
    await saveData();
    notifyListeners();
    return true;
  }

  Future<void> cancelApplication(String applicationId) async {
    applications.removeWhere((a) => a.id == applicationId);
    await saveData();
    notifyListeners();
  }

  List<AppUser> talentList({String query = ''}) {
    final q = query.toLowerCase().trim();
    return users.where((u) {
      if (u.role != UserRole.seeker || !u.openToWork) return false;
      if (q.isEmpty) return true;
      final nameMatch = u.name.toLowerCase().contains(q);
      final skillMatch = u.skills.any((s) => s.toLowerCase().contains(q));
      return nameMatch || skillMatch;
    }).toList();
  }

  List<Job> jobsForEmployer(String employerId) {
    final list = jobs.where((j) => j.employerId == employerId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Application> applicantsForJob(String jobId) {
    return applications.where((a) => a.jobId == jobId).toList().reversed.toList();
  }

  Future<void> postJob({
    required String title,
    required String category,
    required String pay,
    required String description,
    required String employerId,
    int vacancies = 1,
  }) async {
    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      pay: pay,
      description: description,
      employerId: employerId,
      createdAt: DateTime.now(),
      vacancies: vacancies < 1 ? 1 : vacancies,
    );
    jobs.add(job);
    await saveData();
    notifyListeners();
  }

  // Employers can open or close their own job to new applicants.
  Future<bool> setJobFull(String jobId, bool isFull) async {
    final user = currentUser;
    if (user == null || user.role != UserRole.employer) return false;
    final index = jobs.indexWhere((j) => j.id == jobId);
    if (index == -1 || jobs[index].employerId != user.id) return false;

    jobs[index] = jobs[index].copyWith(isFull: isFull);
    await saveData();
    notifyListeners();
    return true;
  }

  // Delete a job only if the current user owns it.
  Future<bool> deleteJob(String jobId) async {
    final user = currentUser;
    if (user == null) return false;
    final job = jobById(jobId);
    if (job == null || job.employerId != user.id) return false;

    jobs.removeWhere((j) => j.id == jobId);
    applications.removeWhere((a) => a.jobId == jobId);
    invites.removeWhere((i) => i.jobId == jobId);
    // Reviews are kept on purpose so ratings stay on user profiles.
    await saveData();
    notifyListeners();
    return true;
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    final index = applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) return;
    applications[index] = applications[index].copyWith(status: status);

    // Close the job automatically once all vacancies are filled.
    if (status == ApplicationStatus.hired) {
      final jobId = applications[index].jobId;
      final jobIndex = jobs.indexWhere((j) => j.id == jobId);
      if (jobIndex != -1) {
        final job = jobs[jobIndex];
        if (!job.isFull && hiredCount(jobId) >= job.vacancies) {
          jobs[jobIndex] = job.copyWith(isFull: true);
        }
      }
    }

    await saveData();
    notifyListeners();
  }

  Future<void> sendInvite({
    required String jobId,
    required String employerId,
    required String seekerId,
  }) async {
    final invite = Invite(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jobId: jobId,
      employerId: employerId,
      seekerId: seekerId,
      createdAt: DateTime.now(),
    );
    invites.add(invite);
    await saveData();
    notifyListeners();
  }

  List<Invite> invitesForSeeker(String seekerId) {
    return invites.where((i) => i.seekerId == seekerId).toList().reversed.toList();
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? bio,
    List<String>? skills,
    bool? openToWork,
    String? businessName,
    String? location,
    String? resumeFileName,
    bool clearResume = false,
  }) async {
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;
    final old = users[index];
    users[index] = AppUser(
      id: old.id,
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : old.name,
      email: old.email,
      password: old.password,
      role: old.role,
      bio: bio ?? old.bio,
      skills: skills ?? old.skills,
      resumeFileName: clearResume ? null : (resumeFileName ?? old.resumeFileName),
      openToWork: openToWork ?? old.openToWork,
      businessName: businessName ?? old.businessName,
      location: location ?? old.location,
    );
    await saveData();
    notifyListeners();
  }

  Future<void> addReview({
    required String fromUserId,
    required String toUserId,
    required String jobId,
    required int stars,
    String comment = '',
  }) async {
    if (stars < 1 || stars > 5) return;
    if (hasReviewed(fromUserId, toUserId, jobId)) return;
    final review = Review(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fromUserId: fromUserId,
      toUserId: toUserId,
      jobId: jobId,
      stars: stars,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );
    reviews.add(review);
    await saveData();
    notifyListeners();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        users = (data['users'] as List)
            .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
            .toList();
        jobs = (data['jobs'] as List)
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList();
        applications = (data['applications'] as List)
            .map((e) => Application.fromJson(e as Map<String, dynamic>))
            .toList();
        reviews = (data['reviews'] as List)
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList();
        invites = (data['invites'] as List? ?? [])
            .map((e) => Invite.fromJson(e as Map<String, dynamic>))
            .toList();
        currentUserId = data['currentUserId'] as String?;
        hasSeenOnboarding = data['hasSeenOnboarding'] as bool? ?? false;
        _ensureDemoAccounts();
      } catch (_) {
        _seedData();
      }
    } else {
      _seedData();
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'users': users.map((e) => e.toJson()).toList(),
      'jobs': jobs.map((e) => e.toJson()).toList(),
      'applications': applications.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'invites': invites.map((e) => e.toJson()).toList(),
      'currentUserId': currentUserId,
      'hasSeenOnboarding': hasSeenOnboarding,
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<void> setSeenOnboarding() async {
    hasSeenOnboarding = true;
    await saveData();
    notifyListeners();
  }

  String? signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? businessName,
  }) {
    final exists = users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return 'Email is already registered.';
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = AppUser(
      id: id,
      name: name,
      email: email,
      password: password,
      role: role,
      businessName: businessName,
    );
    users.add(user);
    currentUserId = id;
    saveData();
    notifyListeners();
    return null;
  }

  String? logIn(String email, String password) {
    for (final u in users) {
      if (u.email.toLowerCase() == email.toLowerCase() && u.password == password) {
        currentUserId = u.id;
        saveData();
        notifyListeners();
        return null;
      }
    }
    return 'Wrong email or password.';
  }

  Future<void> logOut() async {
    currentUserId = null;
    await saveData();
    notifyListeners();
  }

  void _ensureDemoAccounts() {
    if (!users.any((u) => u.email == 'seeker@demo.com')) {
      users.add(AppUser(
        id: 'demo_seeker',
        name: 'Demo Seeker',
        email: 'seeker@demo.com',
        password: '123456',
        role: UserRole.seeker,
        location: 'Davao City',
        openToWork: true,
      ));
    }
    if (!users.any((u) => u.email == 'employer@demo.com')) {
      users.add(AppUser(
        id: 'demo_employer',
        name: 'Demo Employer',
        email: 'employer@demo.com',
        password: '123456',
        role: UserRole.employer,
        businessName: 'Demo Business',
        location: 'Davao City',
      ));
    }
  }

  void _seedData() {
    users = [
      AppUser(
        id: 'demo_seeker',
        name: 'Demo Seeker',
        email: 'seeker@demo.com',
        password: '123456',
        role: UserRole.seeker,
        bio: 'Demo job seeker account.',
        openToWork: true,
        location: 'Davao City',
      ),
      AppUser(
        id: 'demo_employer',
        name: 'Demo Employer',
        email: 'employer@demo.com',
        password: '123456',
        role: UserRole.employer,
        bio: 'Demo business owner account.',
        businessName: 'Demo Business',
        location: 'Davao City',
      ),
      AppUser(
        id: 's1',
        name: 'Maria Santos',
        email: 'maria@example.com',
        password: '123456',
        role: UserRole.seeker,
        bio: 'Hardworking cook with 5 years experience.',
        skills: ['Cooking', 'Food Prep', 'Cleaning'],
        resumeFileName: 'maria_resume.pdf',
        openToWork: true,
        location: 'Bajada, Davao City',
      ),
      AppUser(
        id: 's2',
        name: 'Juan Dela Cruz',
        email: 'juan@example.com',
        password: '123456',
        role: UserRole.seeker,
        bio: 'Experienced driver and delivery rider.',
        skills: ['Driving', 'Delivery', 'Navigation'],
        resumeFileName: 'juan_resume.pdf',
        openToWork: true,
        location: 'Toril, Davao City',
      ),
      AppUser(
        id: 's3',
        name: 'Ana Reyes',
        email: 'ana@example.com',
        password: '123456',
        role: UserRole.seeker,
        bio: 'Detail-oriented housekeeper.',
        skills: ['Housekeeping', 'Laundry', 'Childcare'],
        openToWork: true,
        location: 'Lanang, Davao City',
      ),
      AppUser(
        id: 's4',
        name: 'Carlo Mendoza',
        email: 'carlo@example.com',
        password: '123456',
        role: UserRole.seeker,
        bio: 'Skilled carpenter and handyman.',
        skills: ['Carpentry', 'Painting', 'Repairs'],
        resumeFileName: 'carlo_resume.pdf',
        openToWork: false,
        location: 'Matina, Davao City',
      ),
      AppUser(
        id: 's5',
        name: 'Liza Gomez',
        email: 'liza@example.com',
        password: '123456',
        role: UserRole.seeker,
        bio: 'Friendly sales assistant and cashier.',
        skills: ['Sales', 'Cashiering', 'Customer Service'],
        openToWork: true,
        location: 'Agdao, Davao City',
      ),
      AppUser(
        id: 's6',
        name: 'Ramon Villanueva',
        email: 'ramon@example.com',
        password: '123456',
        role: UserRole.seeker,
        bio: 'Construction worker and welder.',
        skills: ['Welding', 'Construction', 'Masonry'],
        openToWork: true,
        location: 'Buhangin, Davao City',
      ),
      AppUser(
        id: 'e1',
        name: 'Elena Cruz',
        email: 'elena@example.com',
        password: '123456',
        role: UserRole.employer,
        bio: 'Owner of a local eatery.',
        businessName: 'Lola Elena Carinderia',
        location: 'Poblacion District, Davao City',
      ),
      AppUser(
        id: 'e2',
        name: 'Mark Tan',
        email: 'mark@example.com',
        password: '123456',
        role: UserRole.employer,
        bio: 'Managing small retail shops.',
        businessName: 'Tan Sari-Sari & Supplies',
        location: 'Lanang, Davao City',
      ),
      AppUser(
        id: 'e3',
        name: 'Rosa Lim',
        email: 'rosa@example.com',
        password: '123456',
        role: UserRole.employer,
        bio: 'Runs a cleaning service in Davao.',
        businessName: 'Sparkle Clean Davao',
        location: 'Matina, Davao City',
      ),
      AppUser(
        id: 'e4',
        name: 'Pedro Alvarez',
        email: 'pedro@example.com',
        password: '123456',
        role: UserRole.employer,
        bio: 'Construction contractor.',
        businessName: 'Alvarez Builders',
        location: 'Buhangin, Davao City',
      ),
    ];

    jobs = [
      Job(
        id: 'j1',
        title: 'Kitchen Helper',
        category: 'Food Service',
        pay: '₱450/day',
        description: 'Assist in food prep and kitchen cleaning at our carinderia.',
        employerId: 'e1',
        createdAt: DateTime(2026, 11, 10),
        vacancies: 2,
      ),
      Job(
        id: 'j2',
        title: 'Cashier',
        category: 'Retail',
        pay: '₱500/day',
        description: 'Handle cash register and assist customers in our store.',
        employerId: 'e2',
        createdAt: DateTime(2026, 11, 9),
        vacancies: 1,
      ),
      Job(
        id: 'j3',
        title: 'House Cleaner',
        category: 'Cleaning',
        pay: '₱400/day',
        description: 'Part-time house cleaning for residential clients in Matina.',
        employerId: 'e3',
        createdAt: DateTime(2026, 11, 8),
        vacancies: 2,
      ),
      Job(
        id: 'j4',
        title: 'Delivery Rider',
        category: 'Logistics',
        pay: '₱550/day',
        description: 'Deliver supplies around Davao City. Own motorcycle preferred.',
        employerId: 'e2',
        createdAt: DateTime(2026, 11, 11),
        vacancies: 1,
      ),
      Job(
        id: 'j5',
        title: 'Construction Helper',
        category: 'Construction',
        pay: '₱500/day',
        description: 'Assist skilled workers at a site in Buhangin.',
        employerId: 'e4',
        createdAt: DateTime(2026, 11, 7),
        vacancies: 3,
      ),
      Job(
        id: 'j6',
        title: 'Cook',
        category: 'Food Service',
        pay: '₱600/day',
        description: 'Cook Filipino dishes for lunch service in Poblacion.',
        employerId: 'e1',
        createdAt: DateTime(2026, 11, 12),
        vacancies: 1,
      ),
      Job(
        id: 'j7',
        title: 'Store Helper',
        category: 'Retail',
        pay: '₱420/day',
        description: 'Stock shelves and help with inventory in Lanang.',
        employerId: 'e2',
        createdAt: DateTime(2026, 11, 6),
        vacancies: 2,
      ),
      Job(
        id: 'j8',
        title: 'Office Cleaner',
        category: 'Cleaning',
        pay: '₱450/day',
        description: 'Night shift cleaning for a small office in Matina.',
        employerId: 'e3',
        createdAt: DateTime(2026, 11, 5),
        vacancies: 1,
      ),
      Job(
        id: 'j9',
        title: 'Welder',
        category: 'Construction',
        pay: '₱700/day',
        description: 'Experienced welder needed for a residential project.',
        employerId: 'e4',
        createdAt: DateTime(2026, 11, 13),
        vacancies: 1,
      ),
      Job(
        id: 'j10',
        title: 'Dishwasher',
        category: 'Food Service',
        pay: '₱400/day',
        description: 'Keep dishes and kitchen area clean during peak hours.',
        employerId: 'e1',
        createdAt: DateTime(2026, 11, 14),
        vacancies: 2,
      ),
    ];

    applications = [
      Application(id: 'a1', jobId: 'j1', seekerId: 's1', status: ApplicationStatus.hired, appliedAt: DateTime(2026, 11, 3)),
      Application(id: 'a2', jobId: 'j4', seekerId: 's2', status: ApplicationStatus.pending, appliedAt: DateTime(2026, 11, 12)),
      Application(id: 'a3', jobId: 'j3', seekerId: 's3', status: ApplicationStatus.hired, appliedAt: DateTime(2026, 11, 5)),
      Application(id: 'a4', jobId: 'j5', seekerId: 's6', status: ApplicationStatus.rejected, appliedAt: DateTime(2026, 11, 8)),
      Application(id: 'a5', jobId: 'j2', seekerId: 's5', status: ApplicationStatus.pending, appliedAt: DateTime(2026, 11, 14)),
    ];

    reviews = [
      Review(
        id: 'r1',
        fromUserId: 'e1',
        toUserId: 's1',
        jobId: 'j1',
        stars: 5,
        comment: 'Very reliable and hardworking in the kitchen.',
        createdAt: DateTime(2026, 11, 12),
      ),
      Review(
        id: 'r2',
        fromUserId: 'e3',
        toUserId: 's3',
        jobId: 'j3',
        stars: 4,
        comment: 'Thorough cleaning and always on time.',
        createdAt: DateTime(2026, 11, 10),
      ),
      Review(
        id: 'r3',
        fromUserId: 's1',
        toUserId: 'e1',
        jobId: 'j1',
        stars: 5,
        comment: 'Kind employer and fair pay.',
        createdAt: DateTime(2026, 11, 13),
      ),
    ];

    invites = [];

    currentUserId = null;
    hasSeenOnboarding = false;
  }
}
