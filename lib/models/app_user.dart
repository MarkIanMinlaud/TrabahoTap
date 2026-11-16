enum UserRole { seeker, employer }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String bio;
  final List<String> skills;
  final String? resumeFileName;
  final bool openToWork;
  final String? businessName;
  final String location;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.bio = '',
    this.skills = const [],
    this.resumeFileName,
    this.openToWork = false,
    this.businessName,
    this.location = '',
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? bio,
    List<String>? skills,
    String? resumeFileName,
    bool? openToWork,
    String? businessName,
    String? location,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      openToWork: openToWork ?? this.openToWork,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'bio': bio,
      'skills': skills,
      'resumeFileName': resumeFileName,
      'openToWork': openToWork,
      'businessName': businessName,
      'location': location,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      role: UserRole.values.firstWhere((r) => r.name == json['role']),
      bio: json['bio'] as String? ?? '',
      skills: List<String>.from(json['skills'] as List? ?? []),
      resumeFileName: json['resumeFileName'] as String?,
      openToWork: json['openToWork'] as bool? ?? false,
      businessName: json['businessName'] as String?,
      location: json['location'] as String? ?? '',
    );
  }
}
