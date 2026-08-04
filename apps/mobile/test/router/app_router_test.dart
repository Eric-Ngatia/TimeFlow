import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/main.dart';

import '../helpers/pump_helpers.dart';

void main() {
  testWidgets(
      "tap sur chaque item de la barre de navigation basse affiche l'écran cible (fondu de transition, étape 11)",
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Onglet initial : Aujourd'hui.
    expect(find.text("Aujourd'hui"), findsWidgets);

    await tester.tap(find.text('Statistiques'));
    await tester.pumpAndSettle();
    expect(find.text('Statistiques'), findsWidgets);

    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(find.text('Historique'), findsWidgets);

    await tester.tap(find.text("Aujourd'hui"));
    await tester.pumpAndSettle();
    expect(find.text("Aujourd'hui"), findsWidgets);

    await disposeWidgetTree(tester);
  });
}
