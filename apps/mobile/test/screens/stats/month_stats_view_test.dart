import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/activities_dao.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/screens/stats/month_stats_view.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/charts/category_legend.dart';

import '../../helpers/pump_helpers.dart';

void main() {
  testWidgets(
      'affiche la légende fusionnée sur 30 jours glissants sous le donut',
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
    await dao.save(createActivity(
      id: 'a2',
      title: 'Sport hier',
      category: CategoryId.sport,
      startTime: now.subtract(const Duration(days: 1, hours: 1)),
      endTime: now.subtract(const Duration(days: 1)),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: MonthStatsView())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CategoryLegend), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    // Les deux jours (1h chacun) sont fusionnés en une seule ligne « Sport »
    // — même valeur que la carte KPI « Heures totales » existante (le seul
    // total sur la plage vient de Sport), d'où findsWidgets.
    expect(find.text('2h00'), findsWidgets);
    expect(find.text('100%'), findsOneWidget);

    await disposeWidgetTree(tester);
  });
}
