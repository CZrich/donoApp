import 'dart:convert';

import 'package:alimentored/core/config/app_config.dart';
import 'package:alimentored/features/auth/data/auth_repository.dart';
import 'package:alimentored/features/profile/domain/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ProfileRepository {
  ProfileRepository({
    AppConfig config = const AppConfig.fromEnvironment(),
    http.Client? client,
  })  : _baseUri = Uri.parse(config.apiBaseUrl),
        _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;

  Future<UserProfileModel> getProfile(String accessToken) async {
    final response = await _client.get(
      _baseUri.resolve('/api/profile'),
      headers: {
        'authorization': 'Bearer $accessToken',
        'content-type': 'application/json',
      },
    );

    final body = _parseResponse(response);
    return UserProfileModel.fromJson(body);
  }

  Future<UserProfileModel> updateProfile({
    required String accessToken,
    String? displayName,
    String? phone,
    String? avatarPath,
    String? role,
  }) async {
    final payload = <String, dynamic>{};
    if (displayName != null) payload['displayName'] = displayName;
    if (phone != null) payload['phone'] = phone;
    if (avatarPath != null) payload['avatarPath'] = avatarPath;
    if (role != null) payload['role'] = role;

    final response = await _client.put(
      _baseUri.resolve('/api/profile'),
      headers: {
        'authorization': 'Bearer $accessToken',
        'content-type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final body = _parseResponse(response);
    return UserProfileModel.fromJson(body);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException(
        'Respuesta inválida del servidor (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data['message']?.toString() ??
        'Error en el perfil (${response.statusCode})';
    throw AuthException(
      message,
      statusCode: response.statusCode,
      code: data['error']?.toString(),
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
