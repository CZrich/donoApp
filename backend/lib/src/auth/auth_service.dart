import 'dart:convert';

import 'password_hasher.dart';
import 'user_repository.dart';

const _dummyPasswordHash =
    r'$2a$12$C6UzMDM.H6dfI/f/IKxGhu3ecdo7s9JgZdM0iP4T6tG.a5R2E5XJq';

class AuthUser {
  const AuthUser({required this.id, required this.email});

  final String id;
  final String email;
}

class AuthService {
  const AuthService({required this.users, required this.passwords});

  final UserRepository users;
  final PasswordHasher passwords;

  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail) || !_isStrongPassword(password)) {
      throw const InvalidRegistration();
    }
    if (await users.findByEmail(normalizedEmail) != null) {
      throw const EmailAlreadyRegistered();
    }

    try {
      final account = await users.create(
        email: normalizedEmail,
        passwordHash: passwords.hash(password),
      );
      return AuthUser(id: account.id, email: account.email);
    } on DuplicateEmail {
      throw const EmailAlreadyRegistered();
    }
  }

  Future<AuthUser> authenticate({
    required String email,
    required String password,
  }) async {
    final account = await users.findByEmail(email.trim().toLowerCase());
    final passwordMatches = passwords.verify(
      password,
      account?.passwordHash ?? _dummyPasswordHash,
    );
    if (account == null || !passwordMatches) {
      throw const InvalidCredentials();
    }
    return AuthUser(id: account.id, email: account.email);
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  bool _isStrongPassword(String password) =>
      password.length >= 12 &&
      utf8.encode(password).length <= 72 &&
      RegExp('[A-Z]').hasMatch(password) &&
      RegExp('[a-z]').hasMatch(password) &&
      RegExp('[0-9]').hasMatch(password);
}

class InvalidRegistration implements Exception {
  const InvalidRegistration();
}

class EmailAlreadyRegistered implements Exception {
  const EmailAlreadyRegistered();
}

class InvalidCredentials implements Exception {
  const InvalidCredentials();
}
