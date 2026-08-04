import 'package:fl_chart/fl_chart.dart';
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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('2h30'), findsOneWidget);
  });

  testWidgets(
      'les sections se révèlent progressivement puis atteignent le total final (one-shot)',
      (tester) async {
    const minutesByCategory = <CategoryId, int>{
      CategoryId.work: 120,
      CategoryId.sport: 30,
    };
    const totalMinutes = 150.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryDonutChart(minutesByCategory: minutesByCategory),
        ),
      ),
    );

    // Progression intermédiaire (avant la fin des 600ms de chartEntrance) :
    // la somme des sections révélées est strictement inférieure au total.
    await tester.pump(const Duration(milliseconds: 300));
    var pieChart = tester.widget<PieChart>(find.byType(PieChart));
    final intermediateSum =
        pieChart.data.sections.fold<double>(0, (sum, s) => sum + s.value);
    expect(intermediateSum, lessThan(totalMinutes));

    await tester.pumpAndSettle();

    pieChart = tester.widget<PieChart>(find.byType(PieChart));
    final finalSum =
        pieChart.data.sections.fold<double>(0, (sum, s) => sum + s.value);
    expect(finalSum, totalMinutes);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'balayage séquentiel : la première catégorie se remplit avant la seconde',
      (tester) async {
    const minutesByCategory = <CategoryId, int>{
      CategoryId.work: 100,
      CategoryId.sport: 100,
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryDonutChart(minutesByCategory: minutesByCategory),
        ),
      ),
    );

    // À une progression intermédiaire, la catégorie `work` (première dans
    // l'ordre d'itération de la Map, qui suit l'ordre de déclaration de
    // CategoryId) doit être plus proche de sa valeur finale (100) que
    // `sport` (deuxième), voire déjà complète alors que `sport` n'a pas
    // encore commencé à se remplir.
    await tester.pump(const Duration(milliseconds: 200));
    final pieChart = tester.widget<PieChart>(find.byType(PieChart));
    final sections = pieChart.data.sections;

    expect(sections, isNotEmpty);
    final firstValue = sections.first.value;
    final remainingSum =
        sections.skip(1).fold<double>(0, (sum, s) => sum + s.value);
    expect(firstValue, greaterThanOrEqualTo(remainingSum));

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
