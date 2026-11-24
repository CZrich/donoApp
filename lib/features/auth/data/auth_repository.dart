import 'dart:convert';
import 'dart:io';

import 'package:alimentored/core/config/app_config.dart';
import 'package:alimentored/features/auth/domain/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({
    AppConfig config = const AppConfig.fromEnvironment(),
    http.Client? client,
  })  : _baseUri = Uri.parse(config.apiBaseUrl),
        _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;

  Future<({UserAccountModel user, AuthTokensModel tokens})> register({
    required String email,
    required String password,
  }) async {
    final response = await _post('/api/auth/register', {
      'email': email,
      'password': password,
    });

    final body = _parseResponse(response);
    final user = UserAccountModel.fromJson(body['user'] as Map<String, dynamic>);
    final tokens = AuthTokensModel.fromJson(body['tokens'] as Map<String, dynamic>);
    return (user: user, tokens: tokens);
  }

  Future<({UserAccountModel user, AuthTokensModel tokens})> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('/api/auth/login', {
      'email': email,
      'password': password,
    });

    final body = _parseResponse(response);
    final user = UserAccountModel.fromJson(body['user'] as Map<String, dynamic>);
    final tokens = AuthTokensModel.fromJson(body['tokens'] as Map<String, dynamic>);
    return (user: user, tokens: tokens);
  }

  Future<AuthTokensModel> refresh(String refreshToken) async {
    final response = await _post('/api/auth/refresh', {
      'refreshToken': refreshToken,
    });

    final body = _parseResponse(response);
    return AuthTokensModel.fromJson(body['tokens'] as Map<String, dynamic>);
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _post('/api/auth/logout', {
        'refreshToken': refreshToken,
      });
    } catch (_) {
      // Best-effort logout
    }
  }

  Future<UserAccountModel> getMe(String accessToken) async {
    final response = await _client.get(
      _baseUri.resolve('/api/auth/me'),
      headers: {
        'authorization': 'Bearer $accessToken',
        'content-type': 'application/json',
      },
    );

    final body = _parseResponse(response);
    return UserAccountModel.fromJson(body);
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    try {
      return await _client.post(
        _baseUri.resolve(path),
        headers: {'content-type': 'application/json'},
        body: jsonEncode(body),
      );
    } on SocketException {
      throw const AuthException(
        'No se pudo conectar al servidor. Verifica tu conexión a internet.',
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error de conexión: $e');
    }
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

    final code = data['error']?.toString();
    final message = switch (code) {
      'invalid_credentials' => 'Correo o contraseña incorrectos.',
      'email_already_registered' => 'El correo electrónico ya está registrado.',
      'invalid_registration' =>
        'La contraseña debe tener mínimo 12 caracteres, mayúscula, minúscula y número.',
      'invalid_token' => 'La sesión ha expirado. Vuelve a iniciar sesión.',
      _ => data['message']?.toString() ?? 'Ocurrió un error inesperado.',
    };

    throw AuthException(message, statusCode: response.statusCode, code: code);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
