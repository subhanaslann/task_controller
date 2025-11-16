import 'package:json_annotation/json_annotation.dart';
import 'task.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic {
  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  @JsonKey(name: '_count')
  final TaskCount? count;
  final List<Task>? tasks;
  final List<String>? guestUserIds;

  Topic({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.count,
    this.tasks,
    this.guestUserIds,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

@JsonSerializable()
class TaskCount {
  final int tasks;

  TaskCount({required this.tasks});

  factory TaskCount.fromJson(Map<String, dynamic> json) => _$TaskCountFromJson(json);
  Map<String, dynamic> toJson() => _$TaskCountToJson(this);
}
