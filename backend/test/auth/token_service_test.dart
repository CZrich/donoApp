import 'package:alimentored_api/src/auth/token_service.dart';
import 'package:test/test.dart';

void main() {
  group('TokenService', () {
    late TokenService service;

    setUp(() {
      service = TokenService(
        secret: 'test-secret-key-32-bytes-long-min!',
        accessTokenDuration: const Duration(seconds: 1),
        refreshTokenDuration: const Duration(days: 7),
      );
    });

    test('generates and verifies a valid JWT access token', () {
      final token = service.generateAccessToken(
        accountId: 'acc-123',
        email: 'user@example.com',
      );

      final payload = service.verifyAccessToken(token);
      expect(payload.accountId, 'acc-123');
      expect(payload.email, 'user@example.com');
    });

    test('rejects token signed with different secret', () {
      final otherService = TokenService(
        secret: 'different-secret-key-that-does-not-match',
      );
      final token = otherService.generateAccessToken(
        accountId: 'acc-123',
        email: 'user@example.com',
      );

      expect(
        () => service.verifyAccessToken(token),
        throwsA(isA<InvalidTokenException>()),
      );
    });

    test('rejects expired access token', () async {
      final token = service.generateAccessToken(
        accountId: 'acc-123',
        email: 'user@example.com',
      );

      await Future<void>.delayed(const Duration(milliseconds: 1100));

      expect(
        () => service.verifyAccessToken(token),
        throwsA(isA<InvalidTokenException>()),
      );
    });

    test('generates distinct cryptographically random refresh tokens', () {
      final token1 = service.generateRefreshToken();
      final token2 = service.generateRefreshToken();

      expect(token1, isNotEmpty);
      expect(token2, isNotEmpty);
      expect(token1, isNot(token2));
    });

    test('hashes refresh token deterministically with sha256', () {
      final token = service.generateRefreshToken();
      final hash1 = service.hashRefreshToken(token);
      final hash2 = service.hashRefreshToken(token);

      expect(hash1, hasLength(64));
      expect(hash1, hash2);
    });
  });
}
