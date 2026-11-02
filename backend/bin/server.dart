import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

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

  final router = Router()
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
