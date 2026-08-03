import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/data/theme_mode_dao.dart';
import 'package:timeflow_mobile/main.dart';

import 'helpers/pump_helpers.dart';

void main() {
  testWidgets('applique ThemeMode.dark persisté en base au démarrage',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await ThemeModeDao(db).setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);

    await disposeWidgetTree(tester);
  });

  testWidgets('applique ThemeMode.light persisté en base au démarrage',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await ThemeModeDao(db).setThemeMode(ThemeMode.light);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.light);

    await disposeWidgetTree(tester);
  });
}
