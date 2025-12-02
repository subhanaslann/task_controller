// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationStats _$OrganizationStatsFromJson(Map<String, dynamic> json) =>
    OrganizationStats(
      userCount: (json['userCount'] as num).toInt(),
      activeUserCount: (json['activeUserCount'] as num).toInt(),
      taskCount: (json['taskCount'] as num).toInt(),
      activeTaskCount: (json['activeTaskCount'] as num).toInt(),
      completedTaskCount: (json['completedTaskCount'] as num).toInt(),
      topicCount: (json['topicCount'] as num).toInt(),
      activeTopicCount: (json['activeTopicCount'] as num).toInt(),
    );

Map<String, dynamic> _$OrganizationStatsToJson(OrganizationStats instance) =>
    <String, dynamic>{
      'userCount': instance.userCount,
      'activeUserCount': instance.activeUserCount,
      'taskCount': instance.taskCount,
      'activeTaskCount': instance.activeTaskCount,
      'completedTaskCount': instance.completedTaskCount,
      'topicCount': instance.topicCount,
      'activeTopicCount': instance.activeTopicCount,
    };
