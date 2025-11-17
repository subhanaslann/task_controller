import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../../core/utils/constants.dart';

/// TekTech Cache Models
/// 
/// Hive-compatible cache versions of domain models
/// - Type adapters for Hive serialization
/// - Conversion to/from domain models
/// - Cached timestamp for sync logic

class TaskCache {
  final String id;
  final String? topicId;
  final String title;
  final String? note;
  final String? assigneeId;
  final String status;
  final String priority;
  final String? dueDate;
  final String? createdAt;
  final String? updatedAt;
  final String? completedAt;
  final String? topicTitle;
  final String? assigneeName;
  final DateTime cachedAt;
  final bool isDirty; // Modified locally but not synced

  TaskCache({
    required this.id,
    this.topicId,
    required this.title,
    this.note,
    this.assigneeId,
    required this.status,
    required this.priority,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.topicTitle,
    this.assigneeName,
    required this.cachedAt,
    this.isDirty = false,
  });

  /// Convert from domain Task model
  factory TaskCache.fromTask(Task task) {
    return TaskCache(
      id: task.id,
      topicId: task.topicId,
      title: task.title,
      note: task.note,
      assigneeId: task.assigneeId,
      status: task.status.value,
      priority: task.priority.value,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      completedAt: task.completedAt,
      topicTitle: task.topic?.title,
      assigneeName: task.assignee?.name,
      cachedAt: DateTime.now(),
      isDirty: false,
    );
  }

  /// Convert to domain Task model
  Task toTask() {
    return Task(
      id: id,
      topicId: topicId,
      title: title,
      note: note,
      assigneeId: assigneeId,
      status: TaskStatus.fromString(status),
      priority: Priority.fromString(priority),
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      topic: topicTitle != null && topicId != null
          ? TopicRef(id: topicId!, title: topicTitle!)
          : null,
      assignee: assigneeName != null && assigneeId != null
          ? Assignee(id: assigneeId!, name: assigneeName!)
          : null,
    );
  }

  /// Create a dirty copy (for optimistic updates)
  TaskCache copyWithDirty({
    String? title,
    String? note,
    String? status,
    String? priority,
    String? dueDate,
  }) {
    return TaskCache(
      id: id,
      topicId: topicId,
      title: title ?? this.title,
      note: note ?? this.note,
      assigneeId: assigneeId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      completedAt: completedAt,
      topicTitle: topicTitle,
      assigneeName: assigneeName,
      cachedAt: cachedAt,
      isDirty: true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'topicId': topicId,
    'title': title,
    'note': note,
    'assigneeId': assigneeId,
    'status': status,
    'priority': priority,
    'dueDate': dueDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'completedAt': completedAt,
    'topicTitle': topicTitle,
    'assigneeName': assigneeName,
    'cachedAt': cachedAt.toIso8601String(),
    'isDirty': isDirty,
  };

  /// Convert from JSON
  factory TaskCache.fromJson(Map<String, dynamic> json) => TaskCache(
    id: json['id'] as String,
    topicId: json['topicId'] as String?,
    title: json['title'] as String,
    note: json['note'] as String?,
    assigneeId: json['assigneeId'] as String?,
    status: json['status'] as String,
    priority: json['priority'] as String,
    dueDate: json['dueDate'] as String?,
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String,
    completedAt: json['completedAt'] as String?,
    topicTitle: json['topicTitle'] as String?,
    assigneeName: json['assigneeName'] as String?,
    cachedAt: DateTime.parse(json['cachedAt'] as String),
    isDirty: json['isDirty'] as bool? ?? false,
  );
}

class UserCache {
  final String id;
  final String organizationId;
  final String name;
  final String username;
  final String email;
  final String role;
  final bool active;
  final List<String> visibleTopicIds;
  final DateTime cachedAt;

  UserCache({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    required this.active,
    required this.visibleTopicIds,
    required this.cachedAt,
  });

  /// Convert from domain User model
  factory UserCache.fromUser(User user) {
    return UserCache(
      id: user.id,
      organizationId: user.organizationId,
      name: user.name,
      username: user.username,
      email: user.email,
      role: user.role.value,
      active: user.active,
      visibleTopicIds: user.visibleTopicIds,
      cachedAt: DateTime.now(),
    );
  }

  /// Convert to domain User model
  User toUser() {
    return User(
      id: id,
      organizationId: organizationId,
      name: name,
      username: username,
      email: email,
      role: UserRole.fromString(role),
      active: active,
      visibleTopicIds: visibleTopicIds,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'organizationId': organizationId,
    'name': name,
    'username': username,
    'email': email,
    'role': role,
    'active': active,
    'visibleTopicIds': visibleTopicIds,
    'cachedAt': cachedAt.toIso8601String(),
  };

  /// Convert from JSON
  factory UserCache.fromJson(Map<String, dynamic> json) => UserCache(
    id: json['id'] as String,
    organizationId: json['organizationId'] as String? ?? '',
    name: json['name'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    active: json['active'] as bool,
    visibleTopicIds: List<String>.from(json['visibleTopicIds'] as List),
    cachedAt: DateTime.parse(json['cachedAt'] as String),
  );
}

class SyncMetadata {
  final String key;
  final DateTime lastSyncAt;
  final int itemCount;

  SyncMetadata({
    required this.key,
    required this.lastSyncAt,
    required this.itemCount,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'key': key,
    'lastSyncAt': lastSyncAt.toIso8601String(),
    'itemCount': itemCount,
  };

  /// Convert from JSON
  factory SyncMetadata.fromJson(Map<String, dynamic> json) => SyncMetadata(
    key: json['key'] as String,
    lastSyncAt: DateTime.parse(json['lastSyncAt'] as String),
    itemCount: json['itemCount'] as int,
  );
}
