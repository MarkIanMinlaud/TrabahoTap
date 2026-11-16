enum ApplicationStatus { pending, hired, rejected }

class Application {
  final String id;
  final String jobId;
  final String seekerId;
  final ApplicationStatus status;

  Application({
    required this.id,
    required this.jobId,
    required this.seekerId,
    this.status = ApplicationStatus.pending,
  });

  Application copyWith({
    String? id,
    String? jobId,
    String? seekerId,
    ApplicationStatus? status,
  }) {
    return Application(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      seekerId: seekerId ?? this.seekerId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'seekerId': seekerId,
      'status': status.name,
    };
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      seekerId: json['seekerId'] as String,
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ApplicationStatus.pending,
      ),
    );
  }
}
