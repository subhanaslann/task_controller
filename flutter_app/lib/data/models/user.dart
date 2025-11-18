import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/constants.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String organizationId;
  final String name;
  final String username;
  final String email;
  final String? avatar;
  @JsonKey(name: 'role')
  final UserRole role;
  final bool active;
  @JsonKey(name: 'visibleTopicIds', defaultValue: [])
  final List<String> visibleTopicIds;

  User({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.username,
    required this.email,
    this.avatar,
    required this.role,
    required this.active,
    this.visibleTopicIds = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
