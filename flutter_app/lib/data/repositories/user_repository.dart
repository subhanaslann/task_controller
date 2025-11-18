import 'dart:convert';
import 'dart:io';
import '../datasources/api_service.dart';
import '../models/user.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  /// Update user profile with optional name, avatar, and password
  /// Avatar file will be converted to base64 string before sending
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

    final response = await _apiService.updateProfile(
      UpdateProfileRequest(
        name: name,
        avatar: avatarBase64,
        password: password,
      ),
    );

    return response.data;
  }

  /// Get current user profile
  Future<User> getProfile() async {
    final response = await _apiService.getProfile();
    return response.data;
  }
}
