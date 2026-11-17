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
  // Profile photo stored as base64 text so it can live in shared_preferences.
  final String? photoBase64;
  final String contactNumber;
  final String contactEmail;
  final String contactLink;
  final bool showContact;

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
    this.photoBase64,
    this.contactNumber = '',
    this.contactEmail = '',
    this.contactLink = '',
    this.showContact = true,
  });

  bool get hasPhoto => photoBase64 != null && photoBase64!.isNotEmpty;

  bool get hasContactInfo =>
      contactNumber.isNotEmpty ||
      contactEmail.isNotEmpty ||
      contactLink.isNotEmpty;

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
    String? photoBase64,
    String? contactNumber,
    String? contactEmail,
    String? contactLink,
    bool? showContact,
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
      photoBase64: photoBase64 ?? this.photoBase64,
      contactNumber: contactNumber ?? this.contactNumber,
      contactEmail: contactEmail ?? this.contactEmail,
      contactLink: contactLink ?? this.contactLink,
      showContact: showContact ?? this.showContact,
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
      'photoBase64': photoBase64,
      'contactNumber': contactNumber,
      'contactEmail': contactEmail,
      'contactLink': contactLink,
      'showContact': showContact,
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
      // Old saved accounts do not have this key, so keep it null.
      photoBase64: json['photoBase64'] as String?,
      // Contact fields are optional so older saved accounts keep working.
      contactNumber: json['contactNumber'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      contactLink: json['contactLink'] as String? ?? '',
      showContact: json['showContact'] as bool? ?? true,
    );
  }
}
