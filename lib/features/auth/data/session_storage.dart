import 'dart:convert';

import 'package:alimentored/features/auth/domain/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSession {
  const StoredSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserAccountModel user;
}

abstract interface class SessionStorage {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserAccountModel user,
  });

  Future<StoredSession?> getSession();

  Future<void> clearSession();
}

class PreferencesSessionStorage implements SessionStorage {
  const PreferencesSessionStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUser = 'auth_user';

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserAccountModel user,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    await _prefs.setString(_keyRefreshToken, refreshToken);
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  @override
  Future<StoredSession?> getSession() async {
    final accessToken = _prefs.getString(_keyAccessToken);
    final refreshToken = _prefs.getString(_keyRefreshToken);
    final userJson = _prefs.getString(_keyUser);

    if (accessToken == null || refreshToken == null || userJson == null) {
      return null;
    }

    try {
      final user = UserAccountModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      return StoredSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUser);
  }
}

class InMemorySessionStorage implements SessionStorage {
  StoredSession? _session;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserAccountModel user,
  }) async {
    _session = StoredSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  @override
  Future<StoredSession?> getSession() async => _session;

  @override
  Future<void> clearSession() async {
    _session = null;
  }
}

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return InMemorySessionStorage();
});
