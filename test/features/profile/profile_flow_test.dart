import 'dart:convert';

import 'package:alimentored/app/app.dart';
import 'package:alimentored/app/router.dart';
import 'package:alimentored/core/config/app_config.dart';
import 'package:alimentored/features/auth/application/auth_controller.dart';
import 'package:alimentored/features/auth/data/auth_repository.dart';
import 'package:alimentored/features/auth/data/session_storage.dart';
import 'package:alimentored/features/auth/domain/auth_models.dart';
import 'package:alimentored/features/profile/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Profile Repository and Flow', () {
    late InMemorySessionStorage sessionStorage;
    const config = AppConfig(apiBaseUrl: 'http://localhost:8080');

    setUp(() {
      sessionStorage = InMemorySessionStorage();
    });

    test('ProfileRepository getProfile and updateProfile', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer valid-jwt');
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'id': 'user-1',
              'email': 'profile@example.com',
              'role': 'donor',
              'displayName': 'Original Name',
              'phone': '+51987654321',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'PUT') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['displayName'], 'Updated Name');
          return http.Response(
            jsonEncode({
              'id': 'user-1',
              'email': 'profile@example.com',
              'role': 'donor',
              'displayName': 'Updated Name',
              'phone': '+51987654321',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 404);
      });

      final repo = ProfileRepository(config: config, client: mockClient);
      final fetched = await repo.getProfile('valid-jwt');
      expect(fetched.displayName, 'Original Name');

      final updated = await repo.updateProfile(
        accessToken: 'valid-jwt',
        displayName: 'Updated Name',
      );
      expect(updated.displayName, 'Updated Name');
    });

    testWidgets('renders profile data and allows editing with visual feedback',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/me') {
          return http.Response(
            jsonEncode({
              'id': 'u-1',
              'email': 'juan@example.com',
              'role': 'donor',
              'displayName': 'Juan Pérez',
              'phone': '+51987654321',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/profile' && request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'id': 'u-1',
              'email': 'juan@example.com',
              'role': 'donor',
              'displayName': 'Juan Pérez',
              'phone': '+51987654321',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/profile' && request.method == 'PUT') {
          return http.Response(
            jsonEncode({
              'id': 'u-1',
              'email': 'juan@example.com',
              'role': 'donor',
              'displayName': 'Juan Actualizado',
              'phone': '+51999888777',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 200, headers: {'content-type': 'application/json'});
      });

      // Seed active session
      await sessionStorage.saveSession(
        accessToken: 'mock-access',
        refreshToken: 'mock-refresh',
        user: const UserAccountModel(
          id: 'u-1',
          email: 'juan@example.com',
          role: 'donor',
          displayName: 'Juan Pérez',
          phone: '+51987654321',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(sessionStorage),
          authRepositoryProvider.overrideWithValue(
            AuthRepository(config: config, client: mockClient),
          ),
          profileRepositoryProvider.overrideWithValue(
            ProfileRepository(config: config, client: mockClient),
          ),
        ],
      );
      await container.read(authControllerProvider.notifier).initSession();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AlimentoRedApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/profile');
      await tester.pumpAndSettle();

      // Profile details must be displayed
      expect(find.text('Mi Perfil'), findsOneWidget);
      expect(find.text('juan@example.com'), findsWidgets);
      expect(find.text('Donante de alimentos'), findsOneWidget);

      final nameInput = find.byKey(const Key('profile_name_input'));
      expect(nameInput, findsOneWidget);

      // Edit name
      await tester.ensureVisible(nameInput);
      await tester.enterText(nameInput, 'Juan Actualizado');

      final saveButton = find.byKey(const Key('profile_save_button'));
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Visual confirmation feedback
      expect(find.text('Perfil actualizado con éxito.'), findsOneWidget);
    });

    testWidgets('profile allows logout and redirects to welcome page',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/me') {
          return http.Response(
            jsonEncode({
              'id': 'u-1',
              'email': 'juan@example.com',
              'role': 'donor',
              'displayName': 'Juan Pérez',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/profile' && request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'id': 'u-1',
              'email': 'juan@example.com',
              'role': 'donor',
              'displayName': 'Juan Pérez',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 200, headers: {'content-type': 'application/json'});
      });

      await sessionStorage.saveSession(
        accessToken: 'mock-access',
        refreshToken: 'mock-refresh',
        user: const UserAccountModel(
          id: 'u-1',
          email: 'juan@example.com',
          role: 'donor',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(sessionStorage),
          authRepositoryProvider.overrideWithValue(
            AuthRepository(config: config, client: mockClient),
          ),
          profileRepositoryProvider.overrideWithValue(
            ProfileRepository(config: config, client: mockClient),
          ),
        ],
      );
      await container.read(authControllerProvider.notifier).initSession();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AlimentoRedApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/profile');
      await tester.pumpAndSettle();

      // Tap logout
      final logoutButton = find.byKey(const Key('profile_logout_button'));
      await tester.ensureVisible(logoutButton);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Must be back on welcome page
      expect(find.text('CADA ALIMENTO CUENTA'), findsOneWidget);
      expect(await sessionStorage.getSession(), isNull);
    });
  });
}
