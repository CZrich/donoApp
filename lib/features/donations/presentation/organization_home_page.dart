import 'package:alimentored/core/presentation/app_page.dart';
import 'package:alimentored/core/presentation/feature_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrganizationHomePage extends StatelessWidget {
  const OrganizationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'AlimentoRed',
      child: FeaturePlaceholder(
        icon: Icons.food_bank_outlined,
        title: 'Inicio de la organización',
        description:
            'Consultá donaciones vigentes y encontrá alimentos adecuados.',
        action: FilledButton.icon(
          onPressed: () => context.go('/donations'),
          icon: const Icon(Icons.search),
          label: const Text('Explorar donaciones'),
        ),
      ),
    );
  }
}
