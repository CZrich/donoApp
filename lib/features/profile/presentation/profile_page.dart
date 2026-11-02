import 'package:alimentored/core/presentation/app_page.dart';
import 'package:alimentored/core/presentation/feature_placeholder.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Perfil',
      currentIndex: 2,
      child: FeaturePlaceholder(
        icon: Icons.person_outline,
        title: 'Información de coordinación',
        description:
            'El perfil mantendrá los datos necesarios sin permitir cambiar '
            'el rol de la cuenta.',
      ),
    );
  }
}
