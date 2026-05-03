import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  // Token operations
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  // Remember me
  Future<void> setRememberMe(bool value, {String? driverId}) async {
    await _storage.write(
      key: StorageKeys.rememberMe,
      value: value.toString(),
    );
    if (value && driverId != null) {
      await _storage.write(key: StorageKeys.savedDriverId, value: driverId);
    } else if (!value) {
      await _storage.delete(key: StorageKeys.savedDriverId);
    }
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: StorageKeys.rememberMe);
    return value == 'true';
  }

  Future<String?> getSavedDriverId() =>
      _storage.read(key: StorageKeys.savedDriverId);

  // Onboarding
  Future<void> setOnboardingSeen() =>
      _storage.write(key: StorageKeys.hasSeenOnboarding, value: 'true');

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: StorageKeys.hasSeenOnboarding);
    return value == 'true';
  }

  // Clear all
  Future<void> clearAll() => _storage.deleteAll();
}
