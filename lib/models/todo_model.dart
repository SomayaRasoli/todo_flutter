import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  String? id;  // Changed from int? to String? for Firestore document IDs
  String title;
  String description;
  DateTime dueDate;
  String? dueTime;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;

  TodoModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id']?.toString(),
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      dueTime: map['dueTime'],
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TodoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: DateTime.parse(data['dueDate']),
      dueTime: data['dueTime'],
      isCompleted: data['isCompleted'] == true,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
