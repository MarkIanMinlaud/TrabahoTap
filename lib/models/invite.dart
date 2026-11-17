class Invite {
  final String id;
  final String jobId;
  final String employerId;
  final String seekerId;
  final DateTime createdAt;

  Invite({
    required this.id,
    required this.jobId,
    required this.employerId,
    required this.seekerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'employerId': employerId,
      'seekerId': seekerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      employerId: json['employerId'] as String,
      seekerId: json['seekerId'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
