import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth_service.dart';
import 'token_service.dart';

Router createAuthRouter({
  required AuthService authService,
  required TokenService tokenService,
}) {
  final router = Router();

  router.post('/register', (Request request) async {
    final body = await _parseJson(request);
    if (body == null) {
      return _json(
        {'error': 'invalid_json', 'message': 'Invalid JSON body'},
        HttpStatus.badRequest,
      );
    }

    final email = body['email']?.toString() ?? '';
    final password = body['password']?.toString() ?? '';

    try {
      final result = await authService.registerWithSession(
        email: email,
        password: password,
      );
      return _json({
        'user': _userJson(result.user),
        'tokens': _tokensJson(result.tokens),
      }, HttpStatus.created);
    } on InvalidRegistration {
      return _json({
        'error': 'invalid_registration',
        'message':
            'Password must be at least 12 characters, max 72 bytes, with upper, lower, and digit.',
      }, HttpStatus.badRequest);
    } on EmailAlreadyRegistered {
      return _json({
        'error': 'email_already_registered',
        'message': 'An account with this email already exists.',
      }, HttpStatus.conflict);
    }
  });

  router.post('/login', (Request request) async {
    final body = await _parseJson(request);
    if (body == null) {
      return _json(
        {'error': 'invalid_json', 'message': 'Invalid JSON body'},
        HttpStatus.badRequest,
      );
    }

    final email = body['email']?.toString() ?? '';
    final password = body['password']?.toString() ?? '';

    try {
      final result = await authService.loginWithSession(
        email: email,
        password: password,
      );
      return _json({
        'user': _userJson(result.user),
        'tokens': _tokensJson(result.tokens),
      });
    } on InvalidCredentials {
      return _json({
        'error': 'invalid_credentials',
        'message': 'Invalid email or password.',
      }, HttpStatus.unauthorized);
    }
  });

  router.post('/refresh', (Request request) async {
    final body = await _parseJson(request);
    final refreshToken = body?['refreshToken']?.toString() ?? '';
    if (refreshToken.isEmpty) {
      return _json({
        'error': 'missing_token',
        'message': 'refreshToken is required',
      }, HttpStatus.badRequest);
    }

    try {
      final tokens = await authService.refreshSession(refreshToken);
      return _json({'tokens': _tokensJson(tokens)});
    } on InvalidTokenException catch (e) {
      return _json({
        'error': 'invalid_token',
        'message': e.message,
      }, HttpStatus.unauthorized);
    }
  });

  router.post('/logout', (Request request) async {
    final body = await _parseJson(request);
    final refreshToken = body?['refreshToken']?.toString() ?? '';
    if (refreshToken.isNotEmpty) {
      await authService.logout(refreshToken);
    }
    return _json({'status': 'ok'});
  });

  router.get('/me', (Request request) async {
    final authHeader = request.headers['authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return _json({
        'error': 'unauthorized',
        'message': 'Missing or invalid Authorization header.',
      }, HttpStatus.unauthorized);
    }

    final token = authHeader.substring(7).trim();
    try {
      final payload = tokenService.verifyAccessToken(token);
      final user = await authService.getUserById(payload.accountId);
      if (user == null) {
        return _json({
          'error': 'user_not_found',
          'message': 'User account does not exist.',
        }, HttpStatus.notFound);
      }
      return _json(_userJson(user));
    } on InvalidTokenException catch (e) {
      return _json({
        'error': 'invalid_token',
        'message': e.message,
      }, HttpStatus.unauthorized);
    }
  });

  return router;
}

Map<String, Object?> _userJson(AuthUser user) => {
      'id': user.id,
      'email': user.email,
      'role': user.role,
      'displayName': user.displayName,
      'phone': user.phone,
      'avatarPath': user.avatarPath,
    };

Map<String, Object?> _tokensJson(AuthTokens tokens) => {
      'accessToken': tokens.accessToken,
      'refreshToken': tokens.refreshToken,
      'expiresIn': tokens.expiresInSeconds,
    };

Future<Map<String, Object?>?> _parseJson(Request request) async {
  try {
    final content = await request.readAsString();
    if (content.trim().isEmpty) return null;
    final decoded = jsonDecode(content);
    if (decoded is Map<String, Object?>) return decoded;
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  } catch (_) {
    return null;
  }
}

Response _json(Object body, [int statusCode = HttpStatus.ok]) => Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
