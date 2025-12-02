import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

@JsonSerializable()
class Organization {
  final String id;
  final String name;
  final String teamName;
  final String slug;
  final bool isActive;
  final int maxUsers;
  final String createdAt;
  final String updatedAt;

  Organization({
    required this.id,
    required this.name,
    required this.teamName,
    required this.slug,
    required this.isActive,
    required this.maxUsers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}

