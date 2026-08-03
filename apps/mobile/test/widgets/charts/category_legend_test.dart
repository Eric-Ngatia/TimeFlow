import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/charts/category_legend.dart';

void main() {
  testWidgets(
      'affiche une ligne par catégorie non vide avec durée et pourcentage',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryLegend(
            minutesByCategory: <CategoryId, int>{
              CategoryId.work: 90,
              CategoryId.sport: 30
            },
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('1h30'), findsOneWidget);
    expect(find.text('30min'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('masque le pourcentage quand showPercentage est false',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CategoryLegend(
            minutesByCategory: <CategoryId, int>{
              CategoryId.work: 90,
              CategoryId.sport: 30
            },
            showPercentage: false,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('1h30'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('répartition vide → aucune exception, aucune ligne affichée',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
            body: CategoryLegend(minutesByCategory: <CategoryId, int>{})),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Row), findsNothing);
  });
}
