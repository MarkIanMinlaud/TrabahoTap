enum UserRole { seeker, employer }

class AppUser {
  final String id;
  final String name;
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
