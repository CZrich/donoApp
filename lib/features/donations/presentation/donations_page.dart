import 'package:alimentored/core/presentation/app_page.dart';
import 'package:alimentored/core/presentation/feature_placeholder.dart';
import 'package:flutter/material.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Donaciones disponibles',
      child: FeaturePlaceholder(
        icon: Icons.search_rounded,
        title: 'Listado y filtros',
        description:
            'Esta ruta consultará la API y mostrará únicamente donaciones '
            'disponibles y vigentes.',
      ),
    );
  }
}
