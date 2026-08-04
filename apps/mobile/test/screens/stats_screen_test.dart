import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/screens/stats/day_stats_view.dart';
import 'package:timeflow_mobile/screens/stats/month_stats_view.dart';
import 'package:timeflow_mobile/screens/stats/week_stats_view.dart';
import 'package:timeflow_mobile/screens/stats_screen.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/charts/category_donut_chart.dart';
import 'package:timeflow_mobile/widgets/charts/weekly_bar_chart.dart';

import '../helpers/pump_helpers.dart';

void main() {
  Future<AppDatabase> pumpStatsScreen(WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(theme: AppTheme.light(), home: const StatsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets(
      'affiche la vue Jour par défaut (donut de répartition, DayStatsView)',
      (tester) async {
    final db = await pumpStatsScreen(tester);
    addTearDown(db.close);

    expect(find.byType(DayStatsView), findsOneWidget);
    expect(find.byType(CategoryDonutChart), findsOneWidget);
    expect(find.byType(WeeklyBarChart), findsNothing);

    await disposeWidgetTree(tester);
  });

  testWidgets(
      'tap sur « Semaine » affiche WeekStatsView (bar chart) et fait disparaître la vue Jour',
      (tester) async {
    final db = await pumpStatsScreen(tester);
    addTearDown(db.close);

    await tester.tap(find.text('Semaine'));
    await tester.pumpAndSettle();

    expect(find.byType(WeekStatsView), findsOneWidget);
    expect(find.byType(WeeklyBarChart), findsOneWidget);
    expect(find.byType(DayStatsView), findsNothing);
    expect(find.byType(CategoryDonutChart), findsNothing);

    await disposeWidgetTree(tester);
  });

  testWidgets(
      'tap sur « Mois » affiche MonthStatsView et fait disparaître la vue Semaine',
      (tester) async {
    final db = await pumpStatsScreen(tester);
    addTearDown(db.close);

    await tester.tap(find.text('Semaine'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mois'));
    await tester.pumpAndSettle();

    expect(find.byType(MonthStatsView), findsOneWidget);
    expect(find.byType(CategoryDonutChart), findsOneWidget);
    expect(find.byType(WeekStatsView), findsNothing);
    expect(find.byType(WeeklyBarChart), findsNothing);

    await disposeWidgetTree(tester);
  });
}
