import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/activities_dao.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/screens/today_screen.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/theme/motion_tokens.dart';

import '../helpers/pump_helpers.dart';

void main() {
  testWidgets("affiche un état vide quand aucune activité n'existe aujourd'hui", (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light(), home: const TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Aucune activité aujourd'hui."), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await disposeWidgetTree(tester);
  });

  testWidgets('affiche CurrentActivityCard quand une activité est en cours (RG-03)', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ActivitiesDao(db);
    await dao.save(createActivity(
      id: 'a1',
      title: 'Développement',
      category: CategoryId.work,
      startTime: DateTime.now().subtract(const Duration(minutes: 20)),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light(), home: const TodayScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('EN COURS'), findsOneWidget);
    expect(find.text('Développement'), findsWidgets);

    await disposeWidgetTree(tester);
  });

  testWidgets(
      "fermeture d'une activité en cours : CurrentActivityCard disparaît après l'animation",
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ActivitiesDao(db);
    await dao.save(createActivity(
      id: 'a1',
      title: 'Développement',
      category: CategoryId.work,
      startTime: DateTime.now().subtract(const Duration(minutes: 20)),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light(), home: const TodayScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('EN COURS'), findsOneWidget);

    await tester.tap(find.text('Clôturer'));
    // `pump()` bornés (pas `pumpAndSettle()`) : le pouls de `CurrentActivityCard`
    // tourne encore tant que la carte est présente pendant le fondu de sortie.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(MotionTokens.fast);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('EN COURS'), findsNothing);

    await disposeWidgetTree(tester);
  });
}
