import 'package:alimentored/app/app.dart';
import 'package:alimentored/features/auth/application/auth_controller.dart';
import 'package:alimentored/features/auth/data/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sessionStorageProvider.overrideWithValue(PreferencesSessionStorage(prefs)),
    ],
  );

  // Initialize stored session
  await container.read(authControllerProvider.notifier).initSession();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AlimentoRedApp(),
    ),
  );
}
