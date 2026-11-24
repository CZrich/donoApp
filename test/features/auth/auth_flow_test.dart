import 'dart:convert';

import 'package:alimentored/app/app.dart';
import 'package:alimentored/core/config/app_config.dart';
import 'package:alimentored/features/auth/data/auth_repository.dart';
import 'package:alimentored/features/auth/data/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Authentication Flow and Navigation Guards', () {
    late InMemorySessionStorage sessionStorage;

    setUp(() {
      sessionStorage = InMemorySessionStorage();
    });

    Widget createTestApp({required http.Client client}) {
      return ProviderScope(
        overrides: [
          sessionStorageProvider.overrideWithValue(sessionStorage),
          authRepositoryProvider.overrideWithValue(
            AuthRepository(
              config: const AppConfig(apiBaseUrl: 'http://localhost:8080'),
              client: client,
            ),
          ),
        ],
        child: const AlimentoRedApp(),
      );
    }

    Future<void> tapVisible(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    testWidgets('welcome page contains login and register buttons', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((_) async => http.Response('{}', 200));
      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('welcome_login_button')), findsOneWidget);
      expect(find.byKey(const Key('welcome_register_button')), findsOneWidget);
    });

    testWidgets('navigates from welcome to login page', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((_) async => http.Response('{}', 200));
      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('welcome_login_button')));

      expect(find.text('Iniciar sesión'), findsWidgets);
      expect(find.byKey(const Key('login_email_input')), findsOneWidget);
      expect(find.byKey(const Key('login_password_input')), findsOneWidget);
    });

    testWidgets('navigates from welcome to register page', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((_) async => http.Response('{}', 200));
      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('welcome_register_button')));

      expect(find.text('Crear cuenta'), findsWidgets);
      expect(find.byKey(const Key('register_email_input')), findsOneWidget);
      expect(find.byKey(const Key('register_password_input')), findsOneWidget);
      expect(find.byKey(const Key('register_confirm_password_input')), findsOneWidget);
    });

    testWidgets('login form validates required inputs', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((_) async => http.Response('{}', 200));
      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('welcome_login_button')));
      await tapVisible(tester, find.byKey(const Key('login_submit_button')));

      expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    });

    testWidgets('login shows error banner on invalid credentials', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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

      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('welcome_login_button')));

      final emailFinder = find.byKey(const Key('login_email_input'));
      final passFinder = find.byKey(const Key('login_password_input'));
      await tester.ensureVisible(emailFinder);
      await tester.enterText(emailFinder, 'wrong@example.com');
      await tester.ensureVisible(passFinder);
      await tester.enterText(passFinder, 'Wrong-Pass-123');
      await tapVisible(tester, find.byKey(const Key('login_submit_button')));

      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    });

    testWidgets('successful login persists session and navigates to donor home', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'user': {
              'id': 'user-123',
              'email': 'valid@example.com',
            },
            'tokens': {
              'accessToken': 'jwt-access',
              'refreshToken': 'jwt-refresh',
              'expiresIn': 900,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('welcome_login_button')));

      final emailFinder = find.byKey(const Key('login_email_input'));
      final passFinder = find.byKey(const Key('login_password_input'));
      await tester.ensureVisible(emailFinder);
      await tester.enterText(emailFinder, 'valid@example.com');
      await tester.ensureVisible(passFinder);
      await tester.enterText(passFinder, 'Strong-Pass-123');
      await tapVisible(tester, find.byKey(const Key('login_submit_button')));

      expect(find.text('Inicio del donante'), findsOneWidget);

      final stored = await sessionStorage.getSession();
      expect(stored, isNotNull);
      expect(stored!.accessToken, 'jwt-access');
      expect(stored.user.email, 'valid@example.com');
    });

    testWidgets('register validates password security constraints', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((_) async => http.Response('{}', 200));
      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('welcome_register_button')));

      final emailFinder = find.byKey(const Key('register_email_input'));
      final passFinder = find.byKey(const Key('register_password_input'));
      final confirmFinder = find.byKey(const Key('register_confirm_password_input'));

      await tester.ensureVisible(emailFinder);
      await tester.enterText(emailFinder, 'new@example.com');
      await tester.ensureVisible(passFinder);
      await tester.enterText(passFinder, 'short');
      await tester.ensureVisible(confirmFinder);
      await tester.enterText(confirmFinder, 'mismatch');
      await tapVisible(tester, find.byKey(const Key('register_submit_button')));

      expect(
        find.text('La contraseña debe tener al menos 12 caracteres'),
        findsOneWidget,
      );
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('guarded routes redirect to login when unauthenticated', (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((_) async => http.Response('{}', 200));
      await tester.pumpWidget(createTestApp(client: mockClient));
      await tester.pumpAndSettle();

      // Navigate to donor foundation first
      await tapVisible(tester, find.text('Vista de donante'));

      // On donor home, tapping "Publicar una donación" (/publish) should redirect to /login
      await tapVisible(tester, find.text('Publicar una donación'));

      // Should be redirected to login page
      expect(find.byKey(const Key('login_email_input')), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsWidgets);
    });
  });
}
