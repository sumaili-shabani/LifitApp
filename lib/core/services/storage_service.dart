import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/auth.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  final GetStorage _storage;

  StorageService() : _storage = GetStorage();

  // Initialize storage
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Save user data
  Future<void> saveUser(ModelLogin user) async {
    await _storage.write(_userKey, user.toJson());
  }

  // Get user data
  ModelLogin? getUser() {
    final userData = _storage.read(_userKey);
    if (userData != null) {
      return ModelLogin.fromJson(userData);
    }
    return null;
  }

  // Save auth token
  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  // Get auth token
  String? getToken() {
    return _storage.read<String>(_tokenKey);
  }

  // Save both user and token
  Future<void> saveUserSession(ModelLogin user) async {
    await Future.wait([
      saveUser(user),
    ]);
  }

  // Clear all stored data
  Future<void> clearSession() async {
    await _storage.erase();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
