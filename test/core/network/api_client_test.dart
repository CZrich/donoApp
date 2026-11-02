import 'package:alimentored/core/config/app_config.dart';
import 'package:alimentored/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('reports a connected API and database as healthy', () async {
    final client = ApiClient(
      config: const AppConfig(apiBaseUrl: 'http://localhost:8080'),
      client: MockClient((request) async {
        expect(request.url.path, '/health');
        return http.Response('{"status":"ok","database":"connected"}', 200);
      }),
    );

    expect(await client.isHealthy(), isTrue);
  });

  test('reports an unavailable API as unhealthy', () async {
    final client = ApiClient(
      config: const AppConfig(apiBaseUrl: 'http://localhost:8080'),
      client: MockClient((request) async => http.Response('{}', 503)),
    );

    expect(await client.isHealthy(), isFalse);
  });
}
