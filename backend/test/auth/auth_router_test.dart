import 'dart:convert';
import 'dart:io';

import 'package:alimentored_api/src/auth/auth_router.dart';
import 'package:alimentored_api/src/auth/auth_service.dart';
import 'package:alimentored_api/src/auth/password_hasher.dart';
import 'package:alimentored_api/src/auth/session_repository.dart';
import 'package:alimentored_api/src/auth/token_service.dart';
import 'package:alimentored_api/src/auth/user_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('AuthRouter', () {
    late InMemoryUserRepository users;
    late InMemorySessionRepository sessions;
    late TokenService tokens;
    late AuthService authService;
    late Handler handler;

    setUp(() {
      users = InMemoryUserRepository();
      sessions = InMemorySessionRepository();
      tokens = TokenService(
        secret: 'test-secret-key-32-chars-long-here!',
        accessTokenDuration: const Duration(minutes: 5),
        refreshTokenDuration: const Duration(days: 1),
      );
      authService = AuthService(
        users: users,
        passwords: const PasswordHasher(cost: 4),
        sessions: sessions,
        tokens: tokens,
      );
      final router = createAuthRouter(
        authService: authService,
        tokenService: tokens,
      );
      handler = const Pipeline().addHandler(router.call);
    });

    test('POST /register creates user and returns 201 with tokens', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/register'),
        body: jsonEncode({
          'email': 'newuser@example.com',
          'password': 'Strong-Password-123',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.created);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['user']['email'], 'newuser@example.com');
      expect(body['tokens']['accessToken'], isNotEmpty);
      expect(body['tokens']['refreshToken'], isNotEmpty);
    });

    test('POST /register rejects invalid passwords with 400', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/register'),
        body: jsonEncode({
          'email': 'newuser@example.com',
          'password': 'short',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.badRequest);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['error'], 'invalid_registration');
    });

    test('POST /register rejects duplicate email with 409', () async {
      await authService.register(
        email: 'existing@example.com',
        password: 'Strong-Password-123',
      );

      final request = Request(
        'POST',
        Uri.parse('http://localhost/register'),
        body: jsonEncode({
          'email': 'EXISTING@example.com',
          'password': 'Strong-Password-123',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.conflict);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['error'], 'email_already_registered');
    });

    test('POST /login authenticates and returns 200 with tokens', () async {
      await authService.register(
        email: 'user@example.com',
        password: 'Strong-Password-123',
      );

      final request = Request(
        'POST',
        Uri.parse('http://localhost/login'),
        body: jsonEncode({
          'email': 'user@example.com',
          'password': 'Strong-Password-123',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['user']['email'], 'user@example.com');
      expect(body['tokens']['accessToken'], isNotEmpty);
      expect(body['tokens']['refreshToken'], isNotEmpty);
    });

    test('POST /login returns 401 on incorrect credentials', () async {
      await authService.register(
        email: 'user@example.com',
        password: 'Strong-Password-123',
      );

      final request = Request(
        'POST',
        Uri.parse('http://localhost/login'),
        body: jsonEncode({
          'email': 'user@example.com',
          'password': 'Wrong-Password-999',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.unauthorized);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['error'], 'invalid_credentials');
    });

    test('POST /refresh returns new tokens and rotates refreshToken', () async {
      final initial = await authService.registerWithSession(
        email: 'user@example.com',
        password: 'Strong-Password-123',
      );

      final request = Request(
        'POST',
        Uri.parse('http://localhost/refresh'),
        body: jsonEncode({
          'refreshToken': initial.tokens.refreshToken,
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['tokens']['accessToken'], isNotEmpty);
      expect(body['tokens']['refreshToken'], isNot(initial.tokens.refreshToken));
    });

    test('POST /refresh rejects invalid or reused refreshToken with 401', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/refresh'),
        body: jsonEncode({
          'refreshToken': 'non-existent-token',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.unauthorized);
    });

    test('POST /logout revokes the session', () async {
      final initial = await authService.registerWithSession(
        email: 'user@example.com',
        password: 'Strong-Password-123',
      );

      final logoutRequest = Request(
        'POST',
        Uri.parse('http://localhost/logout'),
        body: jsonEncode({
          'refreshToken': initial.tokens.refreshToken,
        }),
        headers: {'content-type': 'application/json'},
      );

      final logoutResponse = await handler(logoutRequest);
      expect(logoutResponse.statusCode, HttpStatus.ok);

      // Subsequent refresh must fail
      final refreshRequest = Request(
        'POST',
        Uri.parse('http://localhost/refresh'),
        body: jsonEncode({
          'refreshToken': initial.tokens.refreshToken,
        }),
        headers: {'content-type': 'application/json'},
      );
      final refreshResponse = await handler(refreshRequest);
      expect(refreshResponse.statusCode, HttpStatus.unauthorized);
    });

    test('GET /me returns user profile with valid Bearer token', () async {
      final initial = await authService.registerWithSession(
        email: 'user@example.com',
        password: 'Strong-Password-123',
      );

      final request = Request(
        'GET',
        Uri.parse('http://localhost/me'),
        headers: {
          'authorization': 'Bearer ${initial.tokens.accessToken}',
        },
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['id'], initial.user.id);
      expect(body['email'], 'user@example.com');
    });

    test('GET /me returns 401 without Bearer token', () async {
      final request = Request('GET', Uri.parse('http://localhost/me'));
      final response = await handler(request);
      expect(response.statusCode, HttpStatus.unauthorized);
    });
  });
}
