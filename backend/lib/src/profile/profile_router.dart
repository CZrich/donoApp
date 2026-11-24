import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../auth/token_service.dart';
import 'profile_repository.dart';

Router createProfileRouter({
  required ProfileRepository profileRepository,
  required TokenService tokenService,
}) {
  final router = Router();

  router.get('/', (Request request) async {
    final caller = _authenticate(request, tokenService);
    if (caller == null) {
      return _json({
        'error': 'unauthorized',
        'message': 'Missing or invalid Authorization header.',
      }, HttpStatus.unauthorized);
    }

    final profile = await profileRepository.findById(caller.accountId);
    if (profile == null) {
      return _json({
        'error': 'profile_not_found',
        'message': 'Profile not found.',
      }, HttpStatus.notFound);
    }

    return _json(profile.toJson());
  });

  router.put('/', (Request request) async {
    final caller = _authenticate(request, tokenService);
    if (caller == null) {
      return _json({
        'error': 'unauthorized',
        'message': 'Missing or invalid Authorization header.',
      }, HttpStatus.unauthorized);
    }

    final body = await _parseJson(request);
    if (body == null) {
      return _json({
        'error': 'invalid_json',
        'message': 'Invalid JSON body.',
      }, HttpStatus.badRequest);
    }

    final displayName = body['displayName']?.toString();
    if (displayName != null && displayName.trim().isEmpty) {
      return _json({
        'error': 'invalid_profile_data',
        'message': 'El nombre no puede estar vacío.',
      }, HttpStatus.badRequest);
    }

    final phone = body['phone']?.toString();
    if (phone != null && phone.trim().isEmpty) {
      return _json({
        'error': 'invalid_profile_data',
        'message': 'El teléfono no puede estar vacío.',
      }, HttpStatus.badRequest);
    }

    final role = body['role']?.toString();
    if (role != null && role != 'donor' && role != 'organization') {
      return _json({
        'error': 'invalid_profile_data',
        'message': 'Rol inválido. Debe ser donor u organization.',
      }, HttpStatus.badRequest);
    }

    final avatarPath = body['avatarPath']?.toString();

    try {
      final updated = await profileRepository.update(
        id: caller.accountId,
        displayName: displayName,
        phone: phone,
        avatarPath: avatarPath,
        role: role,
      );
      return _json(updated.toJson());
    } catch (e) {
      return _json({
        'error': 'update_failed',
        'message': e.toString(),
      }, HttpStatus.internalServerError);
    }
  });

  return router;
}

TokenPayload? _authenticate(Request request, TokenService tokenService) {
  final header = request.headers['authorization'];
  if (header == null || !header.startsWith('Bearer ')) return null;
  final token = header.substring(7).trim();
  try {
    return tokenService.verifyAccessToken(token);
  } catch (_) {
    return null;
  }
}

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
