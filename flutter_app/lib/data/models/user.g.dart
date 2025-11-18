// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  name: json['name'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  avatar: json['avatar'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  active: json['active'] as bool,
  visibleTopicIds:
      (json['visibleTopicIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'avatar': instance.avatar,
  'role': _$UserRoleEnumMap[instance.role]!,
  'active': instance.active,
  'visibleTopicIds': instance.visibleTopicIds,
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'ADMIN',
  UserRole.teamManager: 'TEAM_MANAGER',
  UserRole.member: 'MEMBER',
  UserRole.guest: 'GUEST',
};
