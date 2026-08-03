import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/activities_dao.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/screens/stats/week_stats_view.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/charts/category_legend.dart';

import '../../helpers/pump_helpers.dart';

void main() {
  testWidgets(
      'affiche la répartition par catégorie sans pourcentage sous le bar chart',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ActivitiesDao(db);

    final now = DateTime.now();
    await dao.save(createActivity(
      id: 'a1',
      title: 'Sport aujourd’hui',
      category: CategoryId.sport,
      startTime: now.subtract(const Duration(hours: 1)),
      endTime: now,
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: WeekStatsView())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CategoryLegend), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('1h00'), findsWidgets);
    // Pas de pourcentage attendu dans la légende pour la vue Semaine
    // (décision 4 du plan) — le reste de l'écran (KPI « Score moyen ») en
    // affiche un légitimement, d'où le scope sur CategoryLegend.
    expect(
      find.descendant(
          of: find.byType(CategoryLegend), matching: find.textContaining('%')),
      findsNothing,
    );

    await disposeWidgetTree(tester);
  });
}
