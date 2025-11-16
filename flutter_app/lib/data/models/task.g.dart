// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String,
  topicId: json['topicId'] as String?,
  title: json['title'] as String,
  note: json['note'] as String?,
  assigneeId: json['assigneeId'] as String?,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  dueDate: json['dueDate'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  completedAt: json['completedAt'] as String?,
  topic: json['topic'] == null
      ? null
      : TopicRef.fromJson(json['topic'] as Map<String, dynamic>),
  assignee: json['assignee'] == null
      ? null
      : Assignee.fromJson(json['assignee'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'topicId': instance.topicId,
  'title': instance.title,
  'note': instance.note,
  'assigneeId': instance.assigneeId,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'priority': _$PriorityEnumMap[instance.priority]!,
  'dueDate': instance.dueDate,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'completedAt': instance.completedAt,
  'topic': instance.topic,
  'assignee': instance.assignee,
};

const _$TaskStatusEnumMap = {
  TaskStatus.todo: 'TODO',
  TaskStatus.inProgress: 'IN_PROGRESS',
  TaskStatus.done: 'DONE',
};

const _$PriorityEnumMap = {
  Priority.low: 'LOW',
  Priority.normal: 'NORMAL',
  Priority.high: 'HIGH',
};

TopicRef _$TopicRefFromJson(Map<String, dynamic> json) =>
    TopicRef(id: json['id'] as String, title: json['title'] as String);

Map<String, dynamic> _$TopicRefToJson(TopicRef instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
};

Assignee _$AssigneeFromJson(Map<String, dynamic> json) => Assignee(
  id: json['id'] as String,
  name: json['name'] as String,
  username: json['username'] as String?,
);

Map<String, dynamic> _$AssigneeToJson(Assignee instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
};
