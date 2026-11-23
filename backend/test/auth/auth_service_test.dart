import 'package:alimentored_api/src/auth/auth_service.dart';
import 'package:alimentored_api/src/auth/password_hasher.dart';
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
      final password = 'Aa0!' + ('x' * 69);

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
