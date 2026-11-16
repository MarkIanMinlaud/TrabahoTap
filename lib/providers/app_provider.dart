import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/application.dart';
import '../models/job.dart';
import '../models/review.dart';

class AppProvider extends ChangeNotifier {
  static const String _storageKey = 'trabahotap_data';

  List<AppUser> users = [];
  List<Job> jobs = [];
  List<Application> applications = [];
  List<Review> reviews = [];
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

  double averageRatingFor(String userId) {
    final userReviews = reviews.where((r) => r.toUserId == userId).toList();
    if (userReviews.isEmpty) return 0;
    final total = userReviews.fold<int>(0, (sum, r) => sum + r.stars);
    return total / userReviews.length;
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
      ),
      Job(
        id: 'j2',
        title: 'Cashier',
        category: 'Retail',
        pay: '₱500/day',
        description: 'Handle cash register and assist customers in our store.',
        employerId: 'e2',
        createdAt: DateTime(2026, 11, 9),
      ),
      Job(
        id: 'j3',
        title: 'House Cleaner',
        category: 'Cleaning',
        pay: '₱400/day',
        description: 'Part-time house cleaning for residential clients in Matina.',
        employerId: 'e3',
        createdAt: DateTime(2026, 11, 8),
      ),
      Job(
        id: 'j4',
        title: 'Delivery Rider',
        category: 'Logistics',
        pay: '₱550/day',
        description: 'Deliver supplies around Davao City. Own motorcycle preferred.',
        employerId: 'e2',
        createdAt: DateTime(2026, 11, 11),
      ),
      Job(
        id: 'j5',
        title: 'Construction Helper',
        category: 'Construction',
        pay: '₱500/day',
        description: 'Assist skilled workers at a site in Buhangin.',
        employerId: 'e4',
        createdAt: DateTime(2026, 11, 7),
      ),
      Job(
        id: 'j6',
        title: 'Cook',
        category: 'Food Service',
        pay: '₱600/day',
        description: 'Cook Filipino dishes for lunch service in Poblacion.',
        employerId: 'e1',
        createdAt: DateTime(2026, 11, 12),
      ),
      Job(
        id: 'j7',
        title: 'Store Helper',
        category: 'Retail',
        pay: '₱420/day',
        description: 'Stock shelves and help with inventory in Lanang.',
        employerId: 'e2',
        createdAt: DateTime(2026, 11, 6),
      ),
      Job(
        id: 'j8',
        title: 'Office Cleaner',
        category: 'Cleaning',
        pay: '₱450/day',
        description: 'Night shift cleaning for a small office in Matina.',
        employerId: 'e3',
        createdAt: DateTime(2026, 11, 5),
      ),
      Job(
        id: 'j9',
        title: 'Welder',
        category: 'Construction',
        pay: '₱700/day',
        description: 'Experienced welder needed for a residential project.',
        employerId: 'e4',
        createdAt: DateTime(2026, 11, 13),
      ),
      Job(
        id: 'j10',
        title: 'Dishwasher',
        category: 'Food Service',
        pay: '₱400/day',
        description: 'Keep dishes and kitchen area clean during peak hours.',
        employerId: 'e1',
        createdAt: DateTime(2026, 11, 14),
      ),
    ];

    applications = [
      Application(id: 'a1', jobId: 'j1', seekerId: 's1', status: ApplicationStatus.hired),
      Application(id: 'a2', jobId: 'j4', seekerId: 's2', status: ApplicationStatus.pending),
      Application(id: 'a3', jobId: 'j3', seekerId: 's3', status: ApplicationStatus.hired),
      Application(id: 'a4', jobId: 'j5', seekerId: 's6', status: ApplicationStatus.rejected),
      Application(id: 'a5', jobId: 'j2', seekerId: 's5', status: ApplicationStatus.pending),
    ];

    reviews = [
      Review(
        id: 'r1',
        fromUserId: 'e1',
        toUserId: 's1',
        stars: 5,
        comment: 'Very reliable and hardworking in the kitchen.',
      ),
      Review(
        id: 'r2',
        fromUserId: 'e3',
        toUserId: 's3',
        stars: 4,
        comment: 'Thorough cleaning and always on time.',
      ),
      Review(
        id: 'r3',
        fromUserId: 's1',
        toUserId: 'e1',
        stars: 5,
        comment: 'Kind employer and fair pay.',
      ),
    ];

    currentUserId = null;
    hasSeenOnboarding = false;
  }
}
