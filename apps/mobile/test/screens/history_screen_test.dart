import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/activities_dao.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/screens/history_screen.dart';
import 'package:timeflow_mobile/sheets/day_detail_sheet.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/history_day_item.dart';
import 'package:timeflow_mobile/widgets/score_badge.dart';

import '../helpers/pump_helpers.dart';

void main() {
  testWidgets('filtre les jours affichés par catégorie au tap sur un chip',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ActivitiesDao(db);

    final now = DateTime.now();
    await dao.save(createActivity(
      id: 'a1',
      title: 'Course',
      category: CategoryId.sport,
      startTime: now.subtract(const Duration(hours: 2)),
      endTime: now.subtract(const Duration(hours: 1)),
    ));
    await dao.save(createActivity(
      id: 'a2',
      title: 'Développement',
      category: CategoryId.work,
      startTime: now.subtract(const Duration(hours: 4)),
      endTime: now.subtract(const Duration(hours: 3)),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child:
            MaterialApp(theme: AppTheme.light(), home: const HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucune activité.'), findsNothing);

    // Filtrer sur une catégorie présente (Sport) : le jour reste affiché.
    await tester.tap(find.text('Sport'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune activité.'), findsNothing);

    // Filtrer sur une catégorie absente (Sommeil) : aucun résultat.
    await tester.drag(find.byType(ListView).first, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sommeil'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune activité.'), findsOneWidget);

    // Revenir à « Tout » : le jour réapparaît.
    await tester.drag(find.byType(ListView).first, const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tout'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune activité.'), findsNothing);

    await disposeWidgetTree(tester);
  });

  testWidgets('taper sur un jour ouvre la bottom sheet de détail',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ActivitiesDao(db);

    final now = DateTime.now();
    await dao.save(createActivity(
      id: 'a1',
      title: 'Course',
      category: CategoryId.sport,
      startTime: now.subtract(const Duration(hours: 2)),
      endTime: now.subtract(const Duration(hours: 1)),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child:
            MaterialApp(theme: AppTheme.light(), home: const HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(HistoryDayItem));
    await tester.pumpAndSettle();

    // La sheet s'ouvre en overlay par-dessus l'écran : deux ScoreBadge
    // sont désormais présents (celui de la ligne d'historique et celui de
    // la sheet).
    expect(find.byType(DayDetailSheet), findsOneWidget);
    expect(find.byType(ScoreBadge), findsNWidgets(2));

    // Ferme la sheet avant de démonter l'arbre.
    Navigator.of(tester.element(find.byType(DayDetailSheet))).pop();
    await tester.pumpAndSettle();

    await disposeWidgetTree(tester);
  });
}
