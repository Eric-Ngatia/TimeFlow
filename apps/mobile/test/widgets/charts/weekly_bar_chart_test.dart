import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/charts/weekly_bar_chart.dart';

void main() {
  testWidgets('se rend sans exception avec des jours (RG-07)', (tester) async {
    final days = [
      computeDayStats(date: '2026-08-01', minutesByCategory: const {}, activitiesCount: 0),
      computeDayStats(date: '2026-08-02', minutesByCategory: const {}, activitiesCount: 0),
    ];

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: Scaffold(body: WeeklyBarChart(days: days))),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets("affiche 'Aucune donnée' sans exception quand la liste de jours est vide", (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: WeeklyBarChart(days: []))),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Aucune donnée'), findsOneWidget);
  });
}
