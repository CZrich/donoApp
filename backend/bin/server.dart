import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:alimentored_api/src/auth/auth_router.dart';
import 'package:alimentored_api/src/auth/auth_service.dart';
import 'package:alimentored_api/src/auth/password_hasher.dart';
import 'package:alimentored_api/src/auth/postgres_user_repository.dart';
import 'package:alimentored_api/src/auth/session_repository.dart';
import 'package:alimentored_api/src/auth/token_service.dart';
import 'package:alimentored_api/src/database/migrations.dart';

import 'package:alimentored_api/src/profile/postgres_profile_repository.dart';
import 'package:alimentored_api/src/profile/profile_router.dart';

Future<void> main() async {
  final pool = Pool.withEndpoints([
    Endpoint(
      host: Platform.environment['DB_HOST'] ?? 'localhost',
      port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
      database: Platform.environment['DB_NAME'] ?? 'alimentored',
      username: Platform.environment['DB_USER'] ?? 'alimentored',
      password: Platform.environment['DB_PASSWORD'] ?? 'alimentored_dev',
    ),
  ], settings: const PoolSettings(sslMode: SslMode.disable));
  await runMigrations(
    pool,
    Directory(
      Platform.environment['MIGRATIONS_DIR'] ?? '../database/migrations',
    ),
  );

  final userRepository = PostgresUserRepository(pool);
  final sessionRepository = PostgresSessionRepository(pool);
  final tokenService = TokenService(
    secret: Platform.environment['AUTH_TOKEN_SECRET'],
    accessTokenDuration: Duration(
      minutes: int.parse(Platform.environment['AUTH_ACCESS_TOKEN_MINUTES'] ?? '15'),
    ),
  );
  final authService = AuthService(
    users: userRepository,
    passwords: const PasswordHasher(cost: 12),
    sessions: sessionRepository,
    tokens: tokenService,
  );
  final authRouter = createAuthRouter(
    authService: authService,
    tokenService: tokenService,
  );
  final profileRepository = PostgresProfileRepository(pool);
  final profileRouter = createProfileRouter(
    profileRepository: profileRepository,
    tokenService: tokenService,
  );

  final router = Router()
    ..mount('/api/auth', authRouter.call)
    ..mount('/api/profile', profileRouter.call)
    ..get('/health', (Request request) async {
      try {
        await pool.execute('SELECT 1');
        return _jsonResponse({'status': 'ok', 'database': 'connected'});
      } catch (error) {
        return _jsonResponse({
          'status': 'error',
          'database': 'disconnected',
        }, statusCode: HttpStatus.serviceUnavailable);
      }
    })
    ..get('/api/donations', (Request request) async {
      final result = await pool.execute('''
        SELECT id, title, description, category, quantity, unit, district,
               pickup_deadline, status, created_at
        FROM donations
        WHERE status = 'available' AND pickup_deadline > now()
        ORDER BY created_at DESC
      ''');

      return _jsonResponse(
        result.map((row) => _jsonSafe(row.toColumnMap())).toList(),
      );
    });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addMiddleware(_errors())
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('AlimentoRed API listening on port ${server.port}');

  ProcessSignal.sigterm.watch().listen((_) async {
    await pool.close();
    await server.close(force: true);
  });
}

Response _jsonResponse(Object body, {int statusCode = HttpStatus.ok}) =>
    Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Object? _jsonSafe(Object? value) {
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), _jsonSafe(item)));
  }
  if (value is Iterable) return value.map(_jsonSafe).toList();
  return value;
}

Middleware _cors() =>
    (innerHandler) => (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final response = await innerHandler(request);
      return response.change(headers: {...response.headers, ..._corsHeaders});
    };

const _corsHeaders = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET,POST,PUT,DELETE,OPTIONS',
  'access-control-allow-headers': 'content-type,authorization',
};

Middleware _errors() =>
    (innerHandler) => (request) async {
      try {
        return await innerHandler(request);
      } catch (error, stackTrace) {
        stderr
          ..writeln(error)
          ..writeln(stackTrace);
        return _jsonResponse({
          'error': 'internal_server_error',
        }, statusCode: HttpStatus.internalServerError);
      }
    };
