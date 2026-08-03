import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/history_day_item.dart';

void main() {
  testWidgets('affiche la date formatée, le total et le score', (tester) async {
    final dayStats = computeDayStats(
      date: '2026-07-15',
      minutesByCategory: {CategoryId.work: 120, CategoryId.sport: 30},
      activitiesCount: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: HistoryDayItem(dayStats: dayStats)),
      ),
    );

    expect(find.text('15 juil.'), findsOneWidget);
    expect(find.text('2h30 · 2 activités'), findsOneWidget);
    expect(find.text('${dayStats.productivityScore}%'), findsOneWidget);
  });

  testWidgets('déclenche onTap au tap sur la ligne', (tester) async {
    final dayStats = computeDayStats(
      date: '2026-07-15',
      minutesByCategory: {CategoryId.work: 60},
      activitiesCount: 1,
    );
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: HistoryDayItem(dayStats: dayStats, onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(HistoryDayItem));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
