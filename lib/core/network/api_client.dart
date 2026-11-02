import 'dart:convert';

import 'package:alimentored/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    AppConfig config = const AppConfig.fromEnvironment(),
    http.Client? client,
  }) : _baseUri = Uri.parse(config.apiBaseUrl),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;

  Future<bool> isHealthy() async {
    final response = await _client.get(_baseUri.resolve('/health'));
    if (response.statusCode != 200) return false;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['status'] == 'ok' && body['database'] == 'connected';
  }

  void close() => _client.close();
}
