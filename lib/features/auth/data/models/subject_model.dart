class SubjectModel {
  final String id;
  final String name;
  final String code;
  final String facultyId;
  final String facultyName;
  final int totalClasses;
  final DateTime createdAt;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.facultyId,
    required this.facultyName,
    required this.totalClasses,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'totalClasses': totalClasses,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      facultyId: json['facultyId'] as String,
      facultyName: json['facultyName'] as String,
      totalClasses: json['totalClasses'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
