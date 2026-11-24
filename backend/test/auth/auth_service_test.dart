import 'package:alimentored_api/src/auth/auth_service.dart';
import 'package:alimentored_api/src/auth/password_hasher.dart';
import 'package:alimentored_api/src/auth/session_repository.dart';
import 'package:alimentored_api/src/auth/token_service.dart';
import 'package:alimentored_api/src/auth/user_repository.dart';
import 'package:test/test.dart';

void main() {
  group('AuthService', () {
    late InMemoryUserRepository users;
    late AuthService service;

    setUp(() {
      users = InMemoryUserRepository();
      service = AuthService(
        users: users,
        passwords: const PasswordHasher(cost: 4),
      );
    });

    test('registers a normalized email with a password hash', () async {
      final user = await service.register(
        email: '  USER@Example.COM ',
        password: 'Correct-Horse-123',
      );

      expect(user.email, 'user@example.com');
      final stored = await users.findByEmail('user@example.com');
      expect(stored, isNotNull);
      expect(stored!.passwordHash, isNot('Correct-Horse-123'));
    });

    test('rejects duplicate normalized emails', () async {
      await service.register(
        email: 'user@example.com',
        password: 'Correct-Horse-123',
      );

      expect(
        () => service.register(
          email: 'USER@example.com',
          password: 'Another-Pass-123',
        ),
        throwsA(isA<EmailAlreadyRegistered>()),
      );
    });

    test('authenticates valid credentials without exposing the hash', () async {
      await service.register(
        email: 'user@example.com',
        password: 'Correct-Horse-123',
      );

      final user = await service.authenticate(
        email: 'user@example.com',
        password: 'Correct-Horse-123',
      );

      expect(user.email, 'user@example.com');
    });

    test(
      'returns the same error for unknown email and wrong password',
      () async {
        await service.register(
          email: 'user@example.com',
          password: 'Correct-Horse-123',
        );

        await expectLater(
          service.authenticate(
            email: 'user@example.com',
            password: 'wrong-password',
          ),
          throwsA(isA<InvalidCredentials>()),
        );
        await expectLater(
          service.authenticate(
            email: 'missing@example.com',
            password: 'wrong-password',
          ),
          throwsA(isA<InvalidCredentials>()),
        );
      },
    );

    test('unknown accounts still perform password verification', () async {
      final hasher = CountingPasswordHasher();
      final service = AuthService(
        users: InMemoryUserRepository(),
        passwords: hasher,
      );

      await expectLater(
        service.authenticate(
          email: 'missing@example.com',
          password: 'Wrong-Pass-123',
        ),
        throwsA(isA<InvalidCredentials>()),
      );
      expect(hasher.verifyCalls, 1);
    });

    test('rejects passwords exceeding the bcrypt byte limit', () async {
      final password = 'Aa0!${'x' * 69}';

      await expectLater(
        service.register(email: 'user@example.com', password: password),
        throwsA(isA<InvalidRegistration>()),
      );
    });

    test('rejects malformed email and weak password', () async {
      expect(
        () => service.register(email: 'invalid', password: 'short'),
        throwsA(isA<InvalidRegistration>()),
      );
    });

    group('sessions and tokens', () {
      late InMemorySessionRepository sessions;
      late TokenService tokenService;
      late AuthService sessionAuthService;

      setUp(() {
        sessions = InMemorySessionRepository();
        tokenService = TokenService(
          secret: 'test-secret',
          accessTokenDuration: const Duration(minutes: 5),
          refreshTokenDuration: const Duration(days: 1),
        );
        sessionAuthService = AuthService(
          users: users,
          passwords: const PasswordHasher(cost: 4),
          sessions: sessions,
          tokens: tokenService,
        );
      });

      test('registerWithSession returns user and valid tokens', () async {
        final result = await sessionAuthService.registerWithSession(
          email: 'session@example.com',
          password: 'Correct-Horse-123',
        );

        expect(result.user.email, 'session@example.com');
        expect(result.tokens.accessToken, isNotEmpty);
        expect(result.tokens.refreshToken, isNotEmpty);
        expect(result.tokens.expiresInSeconds, 300);

        final payload = tokenService.verifyAccessToken(result.tokens.accessToken);
        expect(payload.accountId, result.user.id);
        expect(payload.email, result.user.email);
      });

      test('loginWithSession issues new tokens for registered user', () async {
        await sessionAuthService.register(
          email: 'login@example.com',
          password: 'Correct-Horse-123',
        );

        final result = await sessionAuthService.loginWithSession(
          email: 'login@example.com',
          password: 'Correct-Horse-123',
        );

        expect(result.user.email, 'login@example.com');
        expect(result.tokens.accessToken, isNotEmpty);
        expect(result.tokens.refreshToken, isNotEmpty);
      });

      test('refreshSession rotates token and extends session', () async {
        final initial = await sessionAuthService.registerWithSession(
          email: 'refresh@example.com',
          password: 'Correct-Horse-123',
        );

        final refreshed = await sessionAuthService.refreshSession(
          initial.tokens.refreshToken,
        );

        expect(refreshed.accessToken, isNotEmpty);
        expect(refreshed.refreshToken, isNot(initial.tokens.refreshToken));

        // Old refresh token must be invalidated
        await expectLater(
          sessionAuthService.refreshSession(initial.tokens.refreshToken),
          throwsA(isA<InvalidTokenException>()),
        );

        // New refresh token can be used again
        final secondRefresh = await sessionAuthService.refreshSession(
          refreshed.refreshToken,
        );
        expect(secondRefresh.accessToken, isNotEmpty);
      });

      test('logout invalidates the session', () async {
        final session = await sessionAuthService.registerWithSession(
          email: 'logout@example.com',
          password: 'Correct-Horse-123',
        );

        await sessionAuthService.logout(session.tokens.refreshToken);

        await expectLater(
          sessionAuthService.refreshSession(session.tokens.refreshToken),
          throwsA(isA<InvalidTokenException>()),
        );
      });

      test('getUserById retrieves authenticated user details', () async {
        final session = await sessionAuthService.registerWithSession(
          email: 'me@example.com',
          password: 'Correct-Horse-123',
        );

        final fetched = await sessionAuthService.getUserById(session.user.id);
        expect(fetched, isNotNull);
        expect(fetched!.email, 'me@example.com');
      });
    });
  });
}

class CountingPasswordHasher extends PasswordHasher {
  CountingPasswordHasher() : super(cost: 4);

  var verifyCalls = 0;

  @override
  bool verify(String password, String hash) {
    verifyCalls++;
    return false;
  }
}
