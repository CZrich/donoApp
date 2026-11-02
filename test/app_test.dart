import 'package:alimentored/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the AlimentoRed welcome experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AlimentoRedApp()));

    expect(find.text('CADA ALIMENTO CUENTA'), findsOneWidget);
    expect(
      find.text('Conectamos excedentes con mesas que los necesitan.'),
      findsOneWidget,
    );
    expect(find.text('Vista de donante'), findsOneWidget);
    expect(find.text('Vista de organización'), findsOneWidget);
  });

  testWidgets('navigates to the donor foundation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AlimentoRedApp()));

    final donorButton = find.text('Vista de donante');
    await tester.ensureVisible(donorButton);
    await tester.tap(donorButton);
    await tester.pumpAndSettle();

    expect(find.text('Inicio del donante'), findsOneWidget);
    expect(find.text('Publicar una donación'), findsOneWidget);
  });
}
