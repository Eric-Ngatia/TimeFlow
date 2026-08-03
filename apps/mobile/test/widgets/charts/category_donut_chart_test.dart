import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/charts/category_donut_chart.dart';

void main() {
  testWidgets('se rend sans exception avec une répartition non vide',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryDonutChart(
            minutesByCategory: <CategoryId, int>{
              CategoryId.work: 120,
              CategoryId.sport: 30
            },
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      "affiche 'Aucune donnée' sans exception quand la répartition est vide",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
            body: CategoryDonutChart(minutesByCategory: <CategoryId, int>{})),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Aucune donnée'), findsOneWidget);
  });

  testWidgets(
      'se rend sans exception avec study et side_project (RG-06, nouvelles catégories)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryDonutChart(
            minutesByCategory: <CategoryId, int>{
              CategoryId.study: 30,
              CategoryId.side_project: 30,
            },
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('se rend sans exception avec les 8 catégories ensemble',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryDonutChart(
            minutesByCategory: <CategoryId, int>{
              CategoryId.work: 60,
              CategoryId.study: 30,
              CategoryId.side_project: 30,
              CategoryId.sport: 30,
              CategoryId.leisure: 30,
              CategoryId.sleep: 60,
              CategoryId.social: 30,
              CategoryId.other: 30,
            },
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('affiche centerLabel par-dessus le donut sans exception',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryDonutChart(
            minutesByCategory: <CategoryId, int>{
              CategoryId.work: 120,
              CategoryId.sport: 30
            },
            centerLabel: Text('2h30'),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('2h30'), findsOneWidget);
  });
}
