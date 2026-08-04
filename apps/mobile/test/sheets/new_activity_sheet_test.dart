import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/sheets/new_activity_sheet.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';

void main() {
  testWidgets('affiche une erreur inline si le titre est vide (RG-01)', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: NewActivitySheet()),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(find.text('Le titre est obligatoire.'), findsOneWidget);
  });

  testWidgets('affiche une erreur inline si aucune catégorie n\'est sélectionnée (RG-01)', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: NewActivitySheet()),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Réunion');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(find.text('La catégorie est obligatoire.'), findsOneWidget);
  });

  testWidgets(
      "l'erreur catégorie apparaît dans un bloc AnimatedSize/AnimatedOpacity",
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: NewActivitySheet()),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Réunion');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    final errorTextFinder = find.text('La catégorie est obligatoire.');
    expect(errorTextFinder, findsOneWidget);
    expect(
      find.ancestor(of: errorTextFinder, matching: find.byType(AnimatedSize)),
      findsOneWidget,
    );
    expect(
      find.ancestor(
          of: errorTextFinder, matching: find.byType(AnimatedOpacity)),
      findsOneWidget,
    );

    // L'animation se termine sans dépassement de timeout (one-shot).
    await tester.pumpAndSettle();
    expect(errorTextFinder, findsOneWidget);
  });

  testWidgets('enregistre une activité valide et ferme la sheet', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showNewActivitySheet(context),
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();

    // Poignée de glissement Material 3 standard (`showDragHandle: true`) :
    // pas de `Type`/`Key` public exposé, vérifiée via son libellé
    // d'accessibilité (fallback anglais intégré au framework, cf.
    // commentaire équivalent dans `history_screen_test.dart`).
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
    semantics.dispose();

    await tester.enterText(find.byType(TextField), 'Réunion équipe');
    await tester.tap(find.text('Travail'));
    await tester.pump();

    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.byType(NewActivitySheet), findsNothing);
  });
}
