// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) => Organization(
  id: json['id'] as String,
  name: json['name'] as String,
  teamName: json['teamName'] as String,
  slug: json['slug'] as String,
  isActive: json['isActive'] as bool,
  maxUsers: (json['maxUsers'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'teamName': instance.teamName,
      'slug': instance.slug,
      'isActive': instance.isActive,
      'maxUsers': instance.maxUsers,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
