import 'dart:convert';

import 'package:alimentored/core/config/app_config.dart';
import 'package:alimentored/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthRepository', () {
    const config = AppConfig(apiBaseUrl: 'http://localhost:8080');

    test('register returns user and tokens on 201', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/auth/register');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'test@example.com');
        return http.Response(
          jsonEncode({
            'user': {
              'id': 'u-1',
              'email': 'test@example.com',
              'role': null,
              'displayName': null,
            },
            'tokens': {
              'accessToken': 'access-123',
              'refreshToken': 'refresh-456',
              'expiresIn': 900,
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AuthRepository(config: config, client: mockClient);
      final result = await repo.register(
        email: 'test@example.com',
        password: 'Password-12345',
      );

      expect(result.user.id, 'u-1');
      expect(result.user.email, 'test@example.com');
      expect(result.tokens.accessToken, 'access-123');
      expect(result.tokens.refreshToken, 'refresh-456');
    });

    test('login returns user and tokens on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/auth/login');
        return http.Response(
          jsonEncode({
            'user': {
              'id': 'u-1',
              'email': 'test@example.com',
            },
            'tokens': {
              'accessToken': 'access-123',
              'refreshToken': 'refresh-456',
              'expiresIn': 900,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AuthRepository(config: config, client: mockClient);
      final result = await repo.login(
        email: 'test@example.com',
        password: 'Password-12345',
      );

      expect(result.user.email, 'test@example.com');
      expect(result.tokens.accessToken, 'access-123');
    });

    test('login throws AuthException on invalid credentials (401)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': 'invalid_credentials',
            'message': 'Invalid email or password.',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AuthRepository(config: config, client: mockClient);
      expect(
        () => repo.login(email: 'test@example.com', password: 'wrong'),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Correo o contraseña incorrectos'),
        )),
      );
    });

    test('register throws AuthException when email already registered (409)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': 'email_already_registered',
            'message': 'An account with this email already exists.',
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AuthRepository(config: config, client: mockClient);
      expect(
        () => repo.register(
          email: 'dup@example.com',
          password: 'Password-12345',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('ya está registrado'),
        )),
      );
    });

    test('refresh returns new tokens on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/auth/refresh');
        return http.Response(
          jsonEncode({
            'tokens': {
              'accessToken': 'new-access',
              'refreshToken': 'new-refresh',
              'expiresIn': 900,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AuthRepository(config: config, client: mockClient);
      final tokens = await repo.refresh('old-refresh');

      expect(tokens.accessToken, 'new-access');
      expect(tokens.refreshToken, 'new-refresh');
    });

    test('getMe returns current user on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/auth/me');
        expect(request.headers['authorization'], 'Bearer valid-token');
        return http.Response(
          jsonEncode({
            'id': 'u-99',
            'email': 'me@example.com',
            'role': 'donor',
            'displayName': 'Carlos',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AuthRepository(config: config, client: mockClient);
      final user = await repo.getMe('valid-token');

      expect(user.id, 'u-99');
      expect(user.email, 'me@example.com');
      expect(user.role, 'donor');
      expect(user.displayName, 'Carlos');
    });
  });
}
