import 'package:alimentored/core/presentation/app_page.dart';
import 'package:alimentored/core/presentation/feature_placeholder.dart';
import 'package:flutter/material.dart';

class PublishDonationPage extends StatelessWidget {
  const PublishDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Publicar donación',
      child: FeaturePlaceholder(
        icon: Icons.add_photo_alternate_outlined,
        title: 'Formulario de publicación',
        description:
            'Esta ruta alojará fotografía, cantidad, fecha límite y lugar de '
            'recojo.',
      ),
    );
  }
}
