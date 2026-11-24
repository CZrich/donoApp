import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class TokenPayload {
  const TokenPayload({required this.accountId, required this.email});

  final String accountId;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is TokenPayload &&
      other.accountId == accountId &&
      other.email == email;

  @override
  int get hashCode => Object.hash(accountId, email);
}

class InvalidTokenException implements Exception {
  const InvalidTokenException([this.message = 'Invalid token']);

  final String message;

  @override
  String toString() => 'InvalidTokenException: $message';
}

class TokenService {
  TokenService({
    String? secret,
    this.accessTokenDuration = const Duration(minutes: 15),
    this.refreshTokenDuration = const Duration(days: 7),
  })  : _secretKey = SecretKey(secret ?? _defaultSecret);

  static const _defaultSecret = 'alimentored_dev_jwt_secret_do_not_use_in_prod';
  final SecretKey _secretKey;
  final Duration accessTokenDuration;
  final Duration refreshTokenDuration;
  final Random _random = Random.secure();

  String generateAccessToken({
    required String accountId,
    required String email,
  }) {
    final jwt = JWT(
      {
        'sub': accountId,
        'email': email,
      },
      issuer: 'alimentored_api',
    );
    return jwt.sign(
      _secretKey,
      expiresIn: accessTokenDuration,
    );
  }

  TokenPayload verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(
        token,
        _secretKey,
        issuer: 'alimentored_api',
      );
      final payload = jwt.payload as Map<String, dynamic>;
      final sub = payload['sub']?.toString() ?? jwt.subject;
      final email = payload['email']?.toString();
      if (sub == null || email == null) {
        throw const InvalidTokenException('Missing subject or email claim');
      }
      return TokenPayload(accountId: sub, email: email);
    } on JWTException catch (e) {
      throw InvalidTokenException(e.message);
    } catch (e) {
      throw InvalidTokenException(e.toString());
    }
  }

  String generateRefreshToken() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String hashRefreshToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }
}
