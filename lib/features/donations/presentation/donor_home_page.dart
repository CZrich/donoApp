import 'package:alimentored/core/presentation/app_page.dart';
import 'package:alimentored/core/presentation/feature_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DonorHomePage extends StatelessWidget {
  const DonorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'AlimentoRed',
      currentIndex: 0,
      child: FeaturePlaceholder(
        icon: Icons.volunteer_activism_outlined,
        title: 'Inicio del donante',
        description:
            'Desde aquí se publicarán alimentos y se administrarán reservas.',
        action: FilledButton.icon(
          onPressed: () => context.go('/publish'),
          icon: const Icon(Icons.add),
          label: const Text('Publicar una donación'),
        ),
      ),
    );
  }
}
