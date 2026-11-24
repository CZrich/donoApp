import 'dart:convert';
import 'dart:io';

import 'package:alimentored_api/src/auth/token_service.dart';
import 'package:alimentored_api/src/profile/profile_repository.dart';
import 'package:alimentored_api/src/profile/profile_router.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('ProfileRouter', () {
    late InMemoryProfileRepository repository;
    late TokenService tokenService;
    late Handler handler;

    setUp(() {
      repository = InMemoryProfileRepository();
      tokenService = TokenService(
        secret: 'test-secret-key-32-chars-long-here!',
        accessTokenDuration: const Duration(minutes: 5),
      );
      final router = createProfileRouter(
        profileRepository: repository,
        tokenService: tokenService,
      );
      handler = const Pipeline().addHandler(router.call);

      repository.seed(
        const UserProfile(
          id: 'user-1',
          email: 'user1@example.com',
          role: 'donor',
          displayName: 'Juan Pérez',
          phone: '+51987654321',
          avatarPath: 'https://images.example.com/juan.jpg',
        ),
      );
      repository.seed(
        const UserProfile(
          id: 'user-2',
          email: 'user2@example.com',
          role: null,
          displayName: null,
          phone: null,
        ),
      );
    });

    test('GET / returns 401 without Bearer token', () async {
      final request = Request('GET', Uri.parse('http://localhost/'));
      final response = await handler(request);
      expect(response.statusCode, HttpStatus.unauthorized);
    });

    test('GET / returns 200 with profile for authenticated user', () async {
      final token = tokenService.generateAccessToken(
        accountId: 'user-1',
        email: 'user1@example.com',
      );

      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'authorization': 'Bearer $token'},
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['id'], 'user-1');
      expect(body['email'], 'user1@example.com');
      expect(body['role'], 'donor');
      expect(body['displayName'], 'Juan Pérez');
      expect(body['phone'], '+51987654321');
    });

    test('PUT / updates profile fields and returns updated data', () async {
      final token = tokenService.generateAccessToken(
        accountId: 'user-1',
        email: 'user1@example.com',
      );

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/'),
        headers: {
          'authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'displayName': 'Juan Modificado',
          'phone': '+51999888777',
        }),
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['displayName'], 'Juan Modificado');
      expect(body['phone'], '+51999888777');
      // Previous avatar must be preserved
      expect(body['avatarPath'], 'https://images.example.com/juan.jpg');
    });

    test('PUT / protects existing role from accidental overwrite', () async {
      final token = tokenService.generateAccessToken(
        accountId: 'user-1',
        email: 'user1@example.com',
      );

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/'),
        headers: {
          'authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'role': 'organization',
        }),
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      // Role remains 'donor', cannot be overwritten once set
      expect(body['role'], 'donor');
    });

    test('PUT / allows setting initial role when currently null', () async {
      final token = tokenService.generateAccessToken(
        accountId: 'user-2',
        email: 'user2@example.com',
      );

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/'),
        headers: {
          'authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'role': 'organization',
          'displayName': 'Comedor San Martín',
        }),
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['role'], 'organization');
      expect(body['displayName'], 'Comedor San Martín');
    });

    test('PUT / rejects blank display name with 400', () async {
      final token = tokenService.generateAccessToken(
        accountId: 'user-1',
        email: 'user1@example.com',
      );

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/'),
        headers: {
          'authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: jsonEncode({'displayName': '   '}),
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('PUT / rejects invalid role with 400', () async {
      final token = tokenService.generateAccessToken(
        accountId: 'user-1',
        email: 'user1@example.com',
      );

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/'),
        headers: {
          'authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: jsonEncode({'role': 'admin'}),
      );

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.badRequest);
    });
  });
}
