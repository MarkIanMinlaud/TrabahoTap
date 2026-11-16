class Job {
  final String id;
  final String title;
  final String category;
  final String pay;
  final String description;
  final String employerId;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.category,
    required this.pay,
    required this.description,
    required this.employerId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'pay': pay,
      'description': description,
      'employerId': employerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      pay: json['pay'] as String,
      description: json['description'] as String,
      employerId: json['employerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
