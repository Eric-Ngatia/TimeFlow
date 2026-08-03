import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/sheets/day_detail_sheet.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';

void main() {
  testWidgets('affiche la date formatée, le score et les entrées de légende',
      (tester) async {
    // Aucune minute en `work` : le score de productivité (RG-06, work/total)
    // vaut 0, distinct des pourcentages de la légende (sport/leisure) — pas
    // de collision de texte entre le score et la légende dans les assertions.
    final dayStats = computeDayStats(
      date: '2026-07-15',
      minutesByCategory: {CategoryId.sport: 40, CategoryId.leisure: 80},
      activitiesCount: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: DayDetailSheet(dayStats: dayStats)),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('MERCREDI'), findsOneWidget);
    expect(find.text('15 juil.'), findsOneWidget);
    expect(dayStats.productivityScore, 0);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('2h00'), findsOneWidget);
    expect(find.text('40min'), findsOneWidget);
    expect(find.text('1h20'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
  });
}
