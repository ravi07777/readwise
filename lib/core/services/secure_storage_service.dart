import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Encrypted storage for API keys
  Future<void> saveApiKey(String provider, String apiKey) async {
    await _secureStorage.write(key: 'api_key_$provider', value: apiKey);
  }

  Future<String?> getApiKey(String provider) async {
    return await _secureStorage.read(key: 'api_key_$provider');
  }

  Future<void> deleteApiKey(String provider) async {
    await _secureStorage.delete(key: 'api_key_$provider');
  }

  Future<bool> hasApiKey(String provider) async {
    final key = await _secureStorage.read(key: 'api_key_$provider');
    return key != null && key.isNotEmpty;
  }

  Future<Map<String, String>> getAllApiKeys() async {
    final all = await _secureStorage.readAll();
    final apiKeys = <String, String>{};
    for (final entry in all.entries) {
      if (entry.key.startsWith('api_key_')) {
        apiKeys[entry.key.replaceFirst('api_key_', '')] = entry.value;
      }
    }
    return apiKeys;
  }

  // Shared preferences for non-sensitive settings
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});
