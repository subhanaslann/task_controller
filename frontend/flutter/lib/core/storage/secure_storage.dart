import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _organizationKey = 'organization_data';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveOrganization(Map<String, dynamic> organization) async {
    await _storage.write(key: _organizationKey, value: jsonEncode(organization));
  }

  Future<Map<String, dynamic>?> getOrganization() async {
    final data = await _storage.read(key: _organizationKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> deleteOrganization() async {
    await _storage.delete(key: _organizationKey);
  }

  Future<void> clearAll() async {
    await deleteToken();
    await deleteOrganization();
  }
}
