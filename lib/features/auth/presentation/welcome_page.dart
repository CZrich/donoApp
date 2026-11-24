import 'package:alimentored/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Icon(
                          Icons.call_made_rounded,
                          color: AppColors.greenDark,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'CADA ALIMENTO CUENTA',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.lime,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conectamos excedentes con mesas que los necesitan.',
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Publicá o encontrá donaciones de alimentos de manera '
                    'rápida, responsable y cercana.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: const Color(0xFFD8EAE3)),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Vista inicial de la aplicación',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'La autenticación mediante la API se implementará en '
                            'la primera unidad funcional.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            key: const Key('welcome_login_button'),
                            icon: const Icon(Icons.login),
                            label: const Text('Iniciar sesión'),
                            onPressed: () => context.go('/login'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            key: const Key('welcome_register_button'),
                            icon: const Icon(Icons.person_add_outlined),
                            label: const Text('Crear una cuenta'),
                            onPressed: () => context.go('/register'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'o explora sin cuenta',
                                    style: TextStyle(color: Colors.black45, fontSize: 12),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => context.go('/donor'),
                            child: const Text('Vista de donante'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => context.go('/organization'),
                            child: const Text('Vista de organización'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
