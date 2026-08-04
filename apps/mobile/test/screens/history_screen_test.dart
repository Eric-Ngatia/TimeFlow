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
import 'package:timeflow_mobile/utils/date_format_fr.dart';
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

    // Poignée de glissement Material 3 standard (`showDragHandle: true`) :
    // aucun `Type`/`Key` public exposé par le SDK, on vérifie via son
    // libellé d'accessibilité (`MaterialLocalizations.modalBarrierDismissLabel`,
    // « Dismiss » en anglais — fallback intégré au framework, pas de
    // dépendance `flutter_localizations` requise).
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
    semantics.dispose();

    // Ferme la sheet avant de démonter l'arbre.
    Navigator.of(tester.element(find.byType(DayDetailSheet))).pop();
    await tester.pumpAndSettle();

    await disposeWidgetTree(tester);
  });

  testWidgets(
      'affiche tous les jours après pumpAndSettle() malgré le plafond de stagger (> 6 jours)',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ActivitiesDao(db);

    final now = DateTime.now();
    const dayCount = 9;
    final dayLabels = <String>[];
    for (var i = 0; i < dayCount; i++) {
      final start = now.subtract(Duration(days: i, hours: 2));
      await dao.save(createActivity(
        id: 'a$i',
        title: 'Activité jour $i',
        category: CategoryId.work,
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      ));
      dayLabels.add(formatDayLabel(DateTime.parse(formatLocalDate(start))));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child:
            MaterialApp(theme: AppTheme.light(), home: const HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucune activité.'), findsNothing);
    // Le jour le plus récent (index 0, sous le plafond de stagger) est
    // rendu par la fenêtre initiale du `ListView.builder`.
    expect(find.text(dayLabels[0]), findsOneWidget);

    // Le jour le plus ancien (index 8, au-delà du plafond de délai 6×40ms)
    // est bien atteignable en scrollant : la liste entière est rendue
    // malgré le plafonnement du stagger, aucun élément n'est perdu.
    await tester.dragUntilVisible(
      find.text(dayLabels[8]),
      find.byType(ListView).last,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text(dayLabels[8]), findsOneWidget);

    await disposeWidgetTree(tester);
  });
}
