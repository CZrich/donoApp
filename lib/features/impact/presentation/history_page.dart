import 'package:alimentored/core/presentation/app_page.dart';
import 'package:alimentored/core/presentation/feature_placeholder.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Historial e impacto',
      currentIndex: 1,
      child: FeaturePlaceholder(
        icon: Icons.insights_outlined,
        title: 'Impacto verificable',
        description:
            'Los indicadores se calcularán únicamente desde donaciones '
            'confirmadas como entregadas.',
      ),
    );
  }
}
