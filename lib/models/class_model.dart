// lib/models/class_model.dart
class ClassModel {
  final String id;
  final String className;
  final String dosenId;
  final String description;
  final List<String> enrolledStudents;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.className,
    required this.dosenId,
    required this.description,
    required this.enrolledStudents,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'className': className,
      'dosenId': dosenId,
      'description': description,
      'enrolledStudents': enrolledStudents,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      className: map['className'],
      dosenId: map['dosenId'],
      description: map['description'],
      enrolledStudents: List<String>.from(map['enrolledStudents']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}