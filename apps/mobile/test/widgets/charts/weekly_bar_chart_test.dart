import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
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
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets("affiche 'Aucune donnée' sans exception quand la liste de jours est vide", (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: WeeklyBarChart(days: []))),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Aucune donnée'), findsOneWidget);
  });

  testWidgets('les barres poussent de 0 vers totalMin à l\'ouverture (one-shot)', (tester) async {
    final days = [
      computeDayStats(
        date: '2026-08-01',
        minutesByCategory: const {CategoryId.work: 120},
        activitiesCount: 1,
      ),
      computeDayStats(
        date: '2026-08-02',
        minutesByCategory: const {CategoryId.work: 60},
        activitiesCount: 1,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: Scaffold(body: WeeklyBarChart(days: days))),
    );

    // Juste après pumpWidget (avant le post-frame callback qui déclenche la
    // croissance), les barres démarrent à 0.
    var barChart = tester.widget<BarChart>(find.byType(BarChart));
    expect(barChart.data.barGroups[0].barRods[0].toY, 0);
    expect(barChart.data.barGroups[1].barRods[0].toY, 0);

    await tester.pumpAndSettle();

    barChart = tester.widget<BarChart>(find.byType(BarChart));
    expect(barChart.data.barGroups[0].barRods[0].toY, days[0].totalMin.toDouble());
    expect(barChart.data.barGroups[1].barRods[0].toY, days[1].totalMin.toDouble());
    expect(tester.takeException(), isNull);
  });
}
