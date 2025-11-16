import 'package:flutter/foundation.dart';
import '../../data/models/task.dart';
import '../../data/models/user.dart';
import '../../data/models/topic.dart';
import '../utils/constants.dart';

/// TekTech Demo Seed Data
/// 
/// Generates realistic demo data for:
/// - Development testing
/// - UI screenshots
/// - Demo presentations
/// - Integration tests
class SeedData {
  // Demo users
  static final List<User> users = [
    User(
      id: 'user-1',
      name: 'Ahmet Yılmaz',
      username: 'admin',
      email: 'ahmet.yilmaz@tektech.com',
      role: UserRole.admin,
      active: true,
      visibleTopicIds: ['topic-1', 'topic-2', 'topic-3', 'topic-4', 'topic-5'],
    ),
    User(
      id: 'user-2',
      name: 'Ayşe Demir',
      username: 'ayse.demir',
      email: 'ayse.demir@tektech.com',
      role: UserRole.member,
      active: true,
      visibleTopicIds: ['topic-1', 'topic-3'],
    ),
    User(
      id: 'user-3',
      name: 'Mehmet Kaya',
      username: 'mehmet.kaya',
      email: 'mehmet.kaya@tektech.com',
      role: UserRole.member,
      active: true,
      visibleTopicIds: ['topic-2', 'topic-4'],
    ),
    User(
      id: 'user-4',
      name: 'Fatma Şahin',
      username: 'fatma.sahin',
      email: 'fatma.sahin@tektech.com',
      role: UserRole.member,
      active: true,
      visibleTopicIds: ['topic-3'],
    ),
    User(
      id: 'user-5',
      name: 'Ali Çelik',
      username: 'ali.celik',
      email: 'ali.celik@tektech.com',
      role: UserRole.member,
      active: true,
      visibleTopicIds: ['topic-5'],
    ),
  ];

  // Demo topics
  static final List<Topic> topics = [
    Topic(
      id: 'topic-1',
      title: 'Flutter Mobil Geliştirme',
      description: 'Flutter ile cross-platform mobil uygulama geliştirme projeleri',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
    ),
    Topic(
      id: 'topic-2',
      title: 'Backend API Geliştirme',
      description: 'Node.js ve Express ile RESTful API geliştirme',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 85)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 85)).toIso8601String(),
    ),
    Topic(
      id: 'topic-3',
      title: 'UI/UX Tasarım',
      description: 'Kullanıcı deneyimi ve arayüz tasarım çalışmaları',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 80)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 80)).toIso8601String(),
    ),
    Topic(
      id: 'topic-4',
      title: 'DevOps & CI/CD',
      description: 'Deployment, monitoring ve continuous integration süreçleri',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 75)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 75)).toIso8601String(),
    ),
    Topic(
      id: 'topic-5',
      title: 'Testing & QA',
      description: 'Unit test, integration test ve kalite güvence süreçleri',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 70)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 70)).toIso8601String(),
    ),
  ];

  // Demo tasks
  static final List<Task> tasks = [
    // TODO tasks
    Task(
      id: 'task-1',
      topicId: 'topic-1',
      title: 'Login ekranı tasarımı',
      note: 'Material 3 design guidelines kullanarak modern bir login ekranı tasarla. Dark mode desteği ekle.',
      assigneeId: 'user-2',
      status: TaskStatus.todo,
      priority: Priority.high,
      dueDate: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      completedAt: null,
      topic: TopicRef(id: 'topic-1', title: 'Flutter Mobil Geliştirme'),
      assignee: Assignee(id: 'user-2', name: 'Ayşe Demir', username: 'ayse.demir'),
    ),
    Task(
      id: 'task-2',
      topicId: 'topic-2',
      title: 'User authentication API',
      note: 'JWT tabanlı authentication sistemi kur. Refresh token mekanizması ekle.',
      assigneeId: 'user-3',
      status: TaskStatus.todo,
      priority: Priority.high,
      dueDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      completedAt: null,
      topic: TopicRef(id: 'topic-2', title: 'Backend API Geliştirme'),
      assignee: Assignee(id: 'user-3', name: 'Mehmet Kaya', username: 'mehmet.kaya'),
    ),
    Task(
      id: 'task-3',
      topicId: 'topic-3',
      title: 'Color palette seçimi',
      note: 'Brand kimliğine uygun renk paleti belirle. WCAG AA accessibility standartlarına uy.',
      assigneeId: 'user-4',
      status: TaskStatus.todo,
      priority: Priority.normal,
      dueDate: DateTime.now().add(const Duration(days: 10)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      completedAt: null,
      topic: TopicRef(id: 'topic-3', title: 'UI/UX Tasarım'),
      assignee: Assignee(id: 'user-4', name: 'Fatma Şahin', username: 'fatma.sahin'),
    ),
    Task(
      id: 'task-4',
      topicId: 'topic-5',
      title: 'Widget testleri yazılması',
      note: 'Kritik widget\'lar için test coverage %80\'e çıkar.',
      assigneeId: 'user-5',
      status: TaskStatus.todo,
      priority: Priority.normal,
      dueDate: DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      completedAt: null,
      topic: TopicRef(id: 'topic-5', title: 'Testing & QA'),
      assignee: Assignee(id: 'user-5', name: 'Ali Çelik', username: 'ali.celik'),
    ),

    // IN_PROGRESS tasks
    Task(
      id: 'task-5',
      topicId: 'topic-1',
      title: 'Task list ekranı implementasyonu',
      note: 'Pagination, pull-to-refresh ve filter özellikleriyle task list ekranı geliştir.',
      assigneeId: 'user-2',
      status: TaskStatus.inProgress,
      priority: Priority.high,
      dueDate: DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      completedAt: null,
      topic: TopicRef(id: 'topic-1', title: 'Flutter Mobil Geliştirme'),
      assignee: Assignee(id: 'user-2', name: 'Ayşe Demir', username: 'ayse.demir'),
    ),
    Task(
      id: 'task-6',
      topicId: 'topic-2',
      title: 'Task CRUD endpoints',
      note: 'RESTful API ile task oluşturma, okuma, güncelleme ve silme işlemleri.',
      assigneeId: 'user-3',
      status: TaskStatus.inProgress,
      priority: Priority.high,
      dueDate: DateTime.now().add(const Duration(days: 4)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      completedAt: null,
      topic: TopicRef(id: 'topic-2', title: 'Backend API Geliştirme'),
      assignee: Assignee(id: 'user-3', name: 'Mehmet Kaya', username: 'mehmet.kaya'),
    ),
    Task(
      id: 'task-7',
      topicId: 'topic-4',
      title: 'GitHub Actions CI/CD setup',
      note: 'Flutter build, test ve deploy pipeline\'ı kur. Android ve iOS desteği.',
      assigneeId: 'user-1',
      status: TaskStatus.inProgress,
      priority: Priority.normal,
      dueDate: DateTime.now().add(const Duration(days: 6)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      completedAt: null,
      topic: TopicRef(id: 'topic-4', title: 'DevOps & CI/CD'),
      assignee: Assignee(id: 'user-1', name: 'Ahmet Yılmaz', username: 'admin'),
    ),

    // DONE tasks
    Task(
      id: 'task-8',
      topicId: 'topic-1',
      title: 'Flutter proje setup',
      note: 'Yeni Flutter projesi oluştur, dependencies ekle, klasör yapısı kur.',
      assigneeId: 'user-1',
      status: TaskStatus.done,
      priority: Priority.high,
      dueDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      completedAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      topic: TopicRef(id: 'topic-1', title: 'Flutter Mobil Geliştirme'),
      assignee: Assignee(id: 'user-1', name: 'Ahmet Yılmaz', username: 'admin'),
    ),
    Task(
      id: 'task-9',
      topicId: 'topic-2',
      title: 'Database schema tasarımı',
      note: 'PostgreSQL database schema\'sı oluştur. User, Task, Topic tabloları.',
      assigneeId: 'user-3',
      status: TaskStatus.done,
      priority: Priority.high,
      dueDate: DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      completedAt: DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      topic: TopicRef(id: 'topic-2', title: 'Backend API Geliştirme'),
      assignee: Assignee(id: 'user-3', name: 'Mehmet Kaya', username: 'mehmet.kaya'),
    ),
    Task(
      id: 'task-10',
      topicId: 'topic-3',
      title: 'Wireframe hazırlama',
      note: 'Tüm ekranlar için low-fidelity wireframe\'ler çiz.',
      assigneeId: 'user-4',
      status: TaskStatus.done,
      priority: Priority.normal,
      dueDate: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      createdAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      completedAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      topic: TopicRef(id: 'topic-3', title: 'UI/UX Tasarım'),
      assignee: Assignee(id: 'user-4', name: 'Fatma Şahin', username: 'fatma.sahin'),
    ),
  ];

  /// Print seed data summary
  static void printSummary() {
    if (kDebugMode) {
      print('=== Seed Data Summary ===');
      print('Users: ${users.length}');
      print('Topics: ${topics.length}');
      print('Tasks: ${tasks.length}');
      print('  - TODO: ${tasks.where((t) => t.status == TaskStatus.todo).length}');
      print('  - IN_PROGRESS: ${tasks.where((t) => t.status == TaskStatus.inProgress).length}');
      print('  - DONE: ${tasks.where((t) => t.status == TaskStatus.done).length}');
      print('========================');
    }
  }

  /// Get tasks by status
  static List<Task> getTasksByStatus(TaskStatus status) {
    return tasks.where((t) => t.status == status).toList();
  }

  /// Get tasks by priority
  static List<Task> getTasksByPriority(Priority priority) {
    return tasks.where((t) => t.priority == priority).toList();
  }

  /// Get tasks by assignee
  static List<Task> getTasksByAssignee(String assigneeId) {
    return tasks.where((t) => t.assigneeId == assigneeId).toList();
  }

  /// Get user by ID
  static User? getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get topic by ID
  static Topic? getTopicById(String id) {
    try {
      return topics.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
