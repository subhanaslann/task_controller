import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/constants.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final String id;
  final String? organizationId;
  final String? topicId;
  final String title;
  final String? note;
  final String? assigneeId;
  @JsonKey(name: 'status')
  final TaskStatus status;
  @JsonKey(name: 'priority')
  final Priority priority;
  final String? dueDate;
  final String createdAt;
  final String updatedAt;
  final String? completedAt;
  final TopicRef? topic;
  final Assignee? assignee;

  Task({
    required this.id,
    this.organizationId,
    this.topicId,
    required this.title,
    this.note,
    this.assigneeId,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.topic,
    this.assignee,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    TaskStatus? status,
    String? note,
    Priority? priority,
    String? dueDate,
  }) {
    return Task(
      id: id,
      organizationId: organizationId,
      topicId: topicId,
      title: title,
      note: note ?? this.note,
      assigneeId: assigneeId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      topic: topic,
      assignee: assignee,
    );
  }
}

@JsonSerializable()
class TopicRef {
  final String id;
  final String title;

  TopicRef({
    required this.id,
    required this.title,
  });

  factory TopicRef.fromJson(Map<String, dynamic> json) => _$TopicRefFromJson(json);
  Map<String, dynamic> toJson() => _$TopicRefToJson(this);
}

@JsonSerializable()
class Assignee {
  final String id;
  final String name;
  final String? username;

  Assignee({
    required this.id,
    required this.name,
    this.username,
  });

  factory Assignee.fromJson(Map<String, dynamic> json) => _$AssigneeFromJson(json);
  Map<String, dynamic> toJson() => _$AssigneeToJson(this);
}
