import 'dart:convert';
import 'dart:io';
import '../datasources/firebase_service.dart';
import '../models/user.dart';

class UserRepository {
  final FirebaseService _firebaseService;

  UserRepository(this._firebaseService);

  Future<User> updateProfile({
    String? name,
    File? avatarFile,
    String? password,
  }) async {
    String? avatarBase64;

    // Convert image file to base64 if provided
    if (avatarFile != null) {
      final bytes = await avatarFile.readAsBytes();
      avatarBase64 = base64Encode(bytes);
    }

    final userData = await _firebaseService.updateProfile({
      if (name != null) 'name': name,
      if (avatarBase64 != null) 'avatar': avatarBase64,
      if (password != null) 'password': password,
    });

    return User.fromJson(userData);
  }

  Future<User?> getProfile() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) return null;

    final userData = await _firebaseService.getUser(userId);
    if (userData == null) return null;

    return User.fromJson(userData);
  }
}
