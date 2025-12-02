import 'package:json_annotation/json_annotation.dart';

part 'organization_stats.g.dart';

@JsonSerializable()
class OrganizationStats {
  final int userCount;
  final int activeUserCount;
  final int taskCount;
  final int activeTaskCount;
  final int completedTaskCount;
  final int topicCount;
  final int activeTopicCount;

  OrganizationStats({
    required this.userCount,
    required this.activeUserCount,
    required this.taskCount,
    required this.activeTaskCount,
    required this.completedTaskCount,
    required this.topicCount,
    required this.activeTopicCount,
  });

  factory OrganizationStats.fromJson(Map<String, dynamic> json) =>
      _$OrganizationStatsFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrganizationStatsToJson(this);
}

