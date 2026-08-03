import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/score_badge.dart';

void main() {
  testWidgets('affiche le score et le palier « Productive » (RG-06)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: ScoreBadge(score: 75))),
    );

    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Productive'), findsOneWidget);
  });

  testWidgets('affiche le palier « Correcte » pour un score intermédiaire', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: ScoreBadge(score: 45))),
    );

    expect(find.text('Correcte'), findsOneWidget);
  });

  testWidgets('affiche le palier « Peu productive » pour un score bas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: ScoreBadge(score: 10))),
    );

    expect(find.text('Peu productive'), findsOneWidget);
  });

  testWidgets('respecte un seuil personnalisé (RG-06 étendu)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: ScoreBadge(score: 70, threshold: 80)),
      ),
    );

    expect(find.text('Correcte'), findsOneWidget);
  });
}
