import 'dart:convert';

import 'password_hasher.dart';
import 'session_repository.dart';
import 'token_service.dart';
import 'user_repository.dart';

const _dummyPasswordHash =
    r'$2a$12$C6UzMDM.H6dfI/f/IKxGhu3ecdo7s9JgZdM0iP4T6tG.a5R2E5XJq';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.role,
    this.displayName,
    this.phone,
    this.avatarPath,
  });

  final String id;
  final String email;
  final String? role;
  final String? displayName;
  final String? phone;
  final String? avatarPath;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.email == email &&
      other.role == role &&
      other.displayName == displayName &&
      other.phone == phone &&
      other.avatarPath == avatarPath;

  @override
  int get hashCode => Object.hash(
        id,
        email,
        role,
        displayName,
        phone,
        avatarPath,
      );
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
}

class AuthSessionResult {
  const AuthSessionResult({
    required this.user,
    required this.tokens,
  });

  final AuthUser user;
  final AuthTokens tokens;
}

class AuthService {
  const AuthService({
    required this.users,
    required this.passwords,
    this.sessions,
    this.tokens,
  });

  final UserRepository users;
  final PasswordHasher passwords;
  final SessionRepository? sessions;
  final TokenService? tokens;

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
      return AuthUser(
        id: account.id,
        email: account.email,
        role: account.role,
        displayName: account.displayName,
        phone: account.phone,
        avatarPath: account.avatarPath,
      );
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
    return AuthUser(
      id: account.id,
      email: account.email,
      role: account.role,
      displayName: account.displayName,
      phone: account.phone,
      avatarPath: account.avatarPath,
    );
  }

  Future<AuthSessionResult> registerWithSession({
    required String email,
    required String password,
  }) async {
    final user = await register(email: email, password: password);
    final authTokens = await _createSession(user);
    return AuthSessionResult(user: user, tokens: authTokens);
  }

  Future<AuthSessionResult> loginWithSession({
    required String email,
    required String password,
  }) async {
    final user = await authenticate(email: email, password: password);
    final authTokens = await _createSession(user);
    return AuthSessionResult(user: user, tokens: authTokens);
  }

  Future<AuthTokens> refreshSession(String refreshToken) async {
    final sessionRepo = _requireSessions();
    final tokenService = _requireTokens();

    final hash = tokenService.hashRefreshToken(refreshToken);
    final session = await sessionRepo.findValidSession(hash);
    if (session == null) {
      throw const InvalidTokenException('Refresh token is invalid or expired');
    }

    final account = await users.findById(session.accountId);
    if (account == null) {
      throw const InvalidTokenException('User account no longer exists');
    }

    await sessionRepo.deleteSession(hash);
    final user = AuthUser(
      id: account.id,
      email: account.email,
      role: account.role,
      displayName: account.displayName,
      phone: account.phone,
      avatarPath: account.avatarPath,
    );
    return _createSession(user);
  }

  Future<void> logout(String refreshToken) async {
    final sessionRepo = _requireSessions();
    final tokenService = _requireTokens();
    final hash = tokenService.hashRefreshToken(refreshToken);
    await sessionRepo.deleteSession(hash);
  }

  Future<AuthUser?> getUserById(String id) async {
    final account = await users.findById(id);
    if (account == null) return null;
    return AuthUser(
      id: account.id,
      email: account.email,
      role: account.role,
      displayName: account.displayName,
      phone: account.phone,
      avatarPath: account.avatarPath,
    );
  }

  Future<AuthTokens> _createSession(AuthUser user) async {
    final sessionRepo = _requireSessions();
    final tokenService = _requireTokens();

    final accessToken = tokenService.generateAccessToken(
      accountId: user.id,
      email: user.email,
    );
    final refreshToken = tokenService.generateRefreshToken();
    final refreshTokenHash = tokenService.hashRefreshToken(refreshToken);
    final expiresAt =
        DateTime.now().toUtc().add(tokenService.refreshTokenDuration);

    await sessionRepo.createSession(
      accountId: user.id,
      refreshTokenHash: refreshTokenHash,
      expiresAt: expiresAt,
    );

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSeconds: tokenService.accessTokenDuration.inSeconds,
    );
  }

  SessionRepository _requireSessions() {
    final s = sessions;
    if (s == null) {
      throw StateError(
          'SessionRepository is required for session operations');
    }
    return s;
  }

  TokenService _requireTokens() {
    final t = tokens;
    if (t == null) {
      throw StateError('TokenService is required for session operations');
    }
    return t;
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
