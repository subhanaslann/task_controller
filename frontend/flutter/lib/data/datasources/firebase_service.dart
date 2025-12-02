import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final firebase_auth.FirebaseAuth _auth;

  FirebaseService()
      : _firestore = FirebaseFirestore.instance,
        _functions = FirebaseFunctions.instance,
        _auth = firebase_auth.FirebaseAuth.instance;

  // Auth getters
  firebase_auth.FirebaseAuth get auth => _auth;
  firebase_auth.User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // Organization ID from custom claims
  Future<String?> getOrganizationId() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final idTokenResult = await user.getIdTokenResult();
    return idTokenResult.claims?['organizationId'] as String?;
  }

  // ===================
  // Auth Functions
  // ===================

  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    final callable = _functions.httpsCallable('loginUser');
    final result = await callable.call({
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    });

    // Sign in with custom token
    final customToken = result.data['customToken'] as String;
    await _auth.signInWithCustomToken(customToken);

    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> registerTeam({
    required String companyName,
    required String teamName,
    required String managerName,
    required String username,
    required String email,
    required String password,
  }) async {
    final callable = _functions.httpsCallable('registerTeam');
    final result = await callable.call({
      'companyName': companyName,
      'teamName': teamName,
      'managerName': managerName,
      'username': username,
      'email': email,
      'password': password,
    });

    // Sign in with custom token
    final customToken = result.data['customToken'] as String;
    await _auth.signInWithCustomToken(customToken);

    return Map<String, dynamic>.from(result.data);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ===================
  // Task Functions (Callable)
  // ===================

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('createTask');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> createMemberTask(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('createMemberTask');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> updateTask(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('updateTask');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> updateMemberTask(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('updateMemberTask');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> updateTaskStatus(String taskId, String status) async {
    final callable = _functions.httpsCallable('updateTaskStatus');
    final result = await callable.call({
      'taskId': taskId,
      'status': status,
    });
    return Map<String, dynamic>.from(result.data);
  }

  Future<void> deleteTask(String taskId) async {
    final callable = _functions.httpsCallable('deleteTask');
    await callable.call({'taskId': taskId});
  }

  Future<void> deleteMemberTask(String taskId) async {
    final callable = _functions.httpsCallable('deleteMemberTask');
    await callable.call({'taskId': taskId});
  }

  // ===================
  // Task Queries (Firestore SDK)
  // ===================

  Future<List<Map<String, dynamic>>> getMyActiveTasks() async {
    final orgId = await getOrganizationId();
    final userId = currentUserId;
    if (orgId == null || userId == null) return [];

    final snapshot = await _firestore
        .collection('organizations').doc(orgId)
        .collection('tasks')
        .where('assigneeId', isEqualTo: userId)
        .where('status', whereIn: ['TODO', 'IN_PROGRESS'])
        .orderBy('priority', descending: true)
        .orderBy('dueDate')
        .get();

    return snapshot.docs.map((doc) => _taskToMap(doc)).toList();
  }

  Future<List<Map<String, dynamic>>> getTeamActiveTasks() async {
    final orgId = await getOrganizationId();
    if (orgId == null) return [];

    final snapshot = await _firestore
        .collection('organizations').doc(orgId)
        .collection('tasks')
        .where('status', whereIn: ['TODO', 'IN_PROGRESS'])
        .orderBy('priority', descending: true)
        .orderBy('dueDate')
        .get();

    return snapshot.docs.map((doc) => _taskToMap(doc)).toList();
  }

  Future<List<Map<String, dynamic>>> getMyCompletedTasks() async {
    final orgId = await getOrganizationId();
    final userId = currentUserId;
    if (orgId == null || userId == null) return [];

    final snapshot = await _firestore
        .collection('organizations').doc(orgId)
        .collection('tasks')
        .where('assigneeId', isEqualTo: userId)
        .where('status', isEqualTo: 'DONE')
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _taskToMap(doc)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final orgId = await getOrganizationId();
    if (orgId == null) return [];

    final snapshot = await _firestore
        .collection('organizations').doc(orgId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _taskToMap(doc)).toList();
  }

  Map<String, dynamic> _taskToMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      ...data,
      'createdAt': _timestampToIso(data['createdAt']),
      'updatedAt': _timestampToIso(data['updatedAt']),
      'dueDate': _timestampToIso(data['dueDate']),
      'completedAt': _timestampToIso(data['completedAt']),
    };
  }

  // ===================
  // Topic Functions
  // ===================

  Future<Map<String, dynamic>> createTopic(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('createTopic');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> updateTopic(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('updateTopic');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<void> deleteTopic(String topicId) async {
    final callable = _functions.httpsCallable('deleteTopic');
    await callable.call({'topicId': topicId});
  }

  Future<List<Map<String, dynamic>>> getActiveTopics() async {
    final orgId = await getOrganizationId();
    if (orgId == null) return [];

    final snapshot = await _firestore
        .collection('organizations').doc(orgId)
        .collection('topics')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _topicToMap(doc)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllTopics() async {
    final orgId = await getOrganizationId();
    if (orgId == null) return [];

    final snapshot = await _firestore
        .collection('organizations').doc(orgId)
        .collection('topics')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _topicToMap(doc)).toList();
  }

  Map<String, dynamic> _topicToMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      ...data,
      'createdAt': _timestampToIso(data['createdAt']),
      'updatedAt': _timestampToIso(data['updatedAt']),
    };
  }

  // ===================
  // User Functions
  // ===================

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('createUser');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('updateUser');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<void> deleteUser(String userId) async {
    final callable = _functions.httpsCallable('deleteUser');
    await callable.call({'userId': userId});
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('updateProfile');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final orgId = await getOrganizationId();
    if (orgId == null) return [];

    final snapshot = await _firestore
        .collection('organizations').doc(orgId)
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _userToMap(doc)).toList();
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final orgId = await getOrganizationId();
    if (orgId == null) return null;

    final doc = await _firestore
        .collection('organizations').doc(orgId)
        .collection('users').doc(userId)
        .get();

    if (!doc.exists) return null;
    return _userToMap(doc);
  }

  Map<String, dynamic> _userToMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      ...data,
      'createdAt': _timestampToIso(data['createdAt']),
      'updatedAt': _timestampToIso(data['updatedAt']),
    };
  }

  // ===================
  // Organization Functions
  // ===================

  Future<Map<String, dynamic>> updateOrganization(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable('updateOrganization');
    final result = await callable.call(data);
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> getOrganizationStats() async {
    final callable = _functions.httpsCallable('getOrganizationStats');
    final result = await callable.call({});
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>?> getOrganization() async {
    final orgId = await getOrganizationId();
    if (orgId == null) return null;

    final doc = await _firestore
        .collection('organizations').doc(orgId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return {
      'id': doc.id,
      ...data,
      'createdAt': _timestampToIso(data['createdAt']),
      'updatedAt': _timestampToIso(data['updatedAt']),
    };
  }

  // ===================
  // Helpers
  // ===================

  String? _timestampToIso(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate().toIso8601String();
    }
    if (timestamp is String) return timestamp;
    return null;
  }
}
