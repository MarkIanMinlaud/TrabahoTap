class Review {
  final String id;
  final String fromUserId;
  final String toUserId;
  final int stars;
  final String comment;

  Review({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.stars,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'stars': stars,
      'comment': comment,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      stars: json['stars'] as int,
      comment: json['comment'] as String? ?? '',
    );
  }
}
