// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  count: json['_count'] == null
      ? null
      : TaskCount.fromJson(json['_count'] as Map<String, dynamic>),
  tasks: (json['tasks'] as List<dynamic>?)
      ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
      .toList(),
  guestUserIds: (json['guestUserIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  '_count': instance.count,
  'tasks': instance.tasks,
  'guestUserIds': instance.guestUserIds,
};

TaskCount _$TaskCountFromJson(Map<String, dynamic> json) =>
    TaskCount(tasks: (json['tasks'] as num).toInt());

Map<String, dynamic> _$TaskCountToJson(TaskCount instance) => <String, dynamic>{
  'tasks': instance.tasks,
};
