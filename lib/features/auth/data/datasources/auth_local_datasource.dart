import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSource(this._secureStorage, this._prefs);

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
    await _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() => _secureStorage.read(key: StorageKeys.accessToken);
  Future<String?> getRefreshToken() => _secureStorage.read(key: StorageKeys.refreshToken);

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(StorageKeys.userId, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final userJson = _prefs.getString(StorageKeys.userId);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.remove(StorageKeys.userId);
  }
}
