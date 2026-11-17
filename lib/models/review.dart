class Review {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String jobId;
  final int stars;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.jobId,
    required this.stars,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'jobId': jobId,
      'stars': stars,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      jobId: json['jobId'] as String? ?? '',
      stars: json['stars'] as int,
      comment: json['comment'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
