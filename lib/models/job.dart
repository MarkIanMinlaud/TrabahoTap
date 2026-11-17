class Job {
  final String id;
  final String title;
  final String category;
  final String pay;
  final String description;
  final String employerId;
  final DateTime createdAt;
  final int vacancies;
  final bool isFull;

  Job({
    required this.id,
    required this.title,
    required this.category,
    required this.pay,
    required this.description,
    required this.employerId,
    required this.createdAt,
    this.vacancies = 1,
    this.isFull = false,
  });

  Job copyWith({int? vacancies, bool? isFull}) {
    return Job(
      id: id,
      title: title,
      category: category,
      pay: pay,
      description: description,
      employerId: employerId,
      createdAt: createdAt,
      vacancies: vacancies ?? this.vacancies,
      isFull: isFull ?? this.isFull,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'pay': pay,
      'description': description,
      'employerId': employerId,
      'createdAt': createdAt.toIso8601String(),
      'vacancies': vacancies,
      'isFull': isFull,
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
      // Older saved jobs do not have these keys, so keep safe defaults.
      vacancies: (json['vacancies'] as num?)?.toInt() ?? 1,
      isFull: json['isFull'] as bool? ?? false,
    );
  }
}
