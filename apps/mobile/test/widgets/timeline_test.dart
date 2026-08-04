import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/timeline.dart';

void main() {
  testWidgets(
      'affiche les tuiles pour une liste de 3 activités et le tap fonctionne toujours après l\'animation',
      (tester) async {
    final now = DateTime.now();
    final activities = [
      createActivity(
        id: 'a1',
        title: 'Réunion',
        category: CategoryId.work,
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 2, minutes: 30)),
      ),
      createActivity(
        id: 'a2',
        title: 'Sport',
        category: CategoryId.sport,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      createActivity(
        id: 'a3',
        title: 'Lecture',
        category: CategoryId.leisure,
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now.subtract(const Duration(minutes: 30)),
      ),
    ];

    Activity? tapped;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Timeline(
            activities: activities,
            onTapActivity: (activity) => tapped = activity,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Réunion'), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('Lecture'), findsOneWidget);

    await tester.tap(find.text('Sport'));
    await tester.pump();

    expect(tapped?.id, 'a2');
  });

  testWidgets("affiche le message d'état vide après pumpAndSettle()",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Timeline(activities: [])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Aucune activité aujourd'hui."), findsOneWidget);
  });
}
