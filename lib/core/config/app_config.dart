class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  const AppConfig.fromEnvironment()
    : apiBaseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080',
      );

  final String apiBaseUrl;
}
