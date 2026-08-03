import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/activities_dao.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/sheets/activity_detail_sheet.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';

Activity _buildActivity({DateTime? endTime}) => createActivity(
      id: 'a1',
      title: 'Réunion',
      category: CategoryId.work,
      startTime: DateTime.now().subtract(const Duration(minutes: 30)),
      endTime: endTime,
    );

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
      'affiche « Clôturer maintenant » seulement si l\'activité est en cours (RG-03)',
      (tester) async {
    final activity = _buildActivity();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: ActivityDetailSheet(activity: activity)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Clôturer maintenant'), findsOneWidget);
  });

  testWidgets('masque « Clôturer maintenant » si l\'activité est déjà clôturée',
      (tester) async {
    final activity = _buildActivity(endTime: DateTime.now());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: ActivityDetailSheet(activity: activity)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Clôturer maintenant'), findsNothing);
  });

  testWidgets('Modifier ouvre NewActivitySheet pré-rempli (risque #7 du plan)',
      (tester) async {
    final activity = _buildActivity(endTime: DateTime.now());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: ActivityDetailSheet(activity: activity)),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Modifier'));
    await tester.pumpAndSettle();

    expect(find.text("Modifier l'activité"), findsOneWidget);
    expect(find.text('Réunion'), findsWidgets);
  });

  testWidgets(
      'Supprimer demande confirmation avant suppression définitive (RG-08)',
      (tester) async {
    final activity = _buildActivity(endTime: DateTime.now());
    final dao = ActivitiesDao(db);
    await dao.save(activity);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: ActivityDetailSheet(activity: activity)),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text("Supprimer l'activité ?"), findsOneWidget);

    await tester.tap(
      find.descendant(
          of: find.byType(AlertDialog), matching: find.text('Supprimer')),
    );
    await tester.pumpAndSettle();

    // `tester.runAsync` : le `NativeDatabase` (FFI) signale ses changements via
    // un vrai `Timer`/port d'isolate, que l'horloge simulée de `testWidgets`
    // n'avance jamais. Sans ce wrapper, `.first` juste après une suppression
    // pilotée par l'UI bloque indéfiniment (`_RawReceivePort._handleMessage`).
    await tester.runAsync(() async {
      final remaining = await dao.watchByDate(activity.date).first;
      expect(remaining, isEmpty);
    });
  });

  testWidgets(
    'Modifier et Supprimer sont côte à côte sur la même ligne, activité en cours',
    (tester) async {
      final activity = _buildActivity(); // en cours (RG-03)

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(body: ActivityDetailSheet(activity: activity)),
          ),
        ),
      );
      await tester.pump();

      final modifierTop =
          tester.getTopLeft(find.widgetWithText(OutlinedButton, 'Modifier'));
      final supprimerTop =
          tester.getTopLeft(find.widgetWithText(TextButton, 'Supprimer'));

      // Même ligne : même position verticale, position horizontale différente.
      expect(modifierTop.dy, supprimerTop.dy);
      expect(modifierTop.dx, isNot(supprimerTop.dx));
    },
  );

  testWidgets(
    'Modifier et Supprimer sont côte à côte sur la même ligne, activité terminée',
    (tester) async {
      final activity = _buildActivity(endTime: DateTime.now());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(body: ActivityDetailSheet(activity: activity)),
          ),
        ),
      );
      await tester.pump();

      // Pas de bouton « Clôturer maintenant » : Modifier/Supprimer restent
      // dans le même `Row`, sans duplication de layout selon `isInProgress`.
      expect(find.text('Clôturer maintenant'), findsNothing);

      final modifierTop =
          tester.getTopLeft(find.widgetWithText(OutlinedButton, 'Modifier'));
      final supprimerTop =
          tester.getTopLeft(find.widgetWithText(TextButton, 'Supprimer'));

      expect(modifierTop.dy, supprimerTop.dy);
      expect(modifierTop.dx, isNot(supprimerTop.dx));
    },
  );

  testWidgets('Annuler dans la confirmation ne supprime pas l\'activité',
      (tester) async {
    final activity = _buildActivity(endTime: DateTime.now());
    final dao = ActivitiesDao(db);
    await dao.save(activity);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: ActivityDetailSheet(activity: activity)),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    // Voir le commentaire du test « Supprimer » ci-dessus : `.first` sur un
    // `NativeDatabase` doit passer par `tester.runAsync` dans `testWidgets`.
    await tester.runAsync(() async {
      final remaining = await dao.watchByDate(activity.date).first;
      expect(remaining, hasLength(1));
    });
  });
}
