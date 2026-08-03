import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/application/activities_provider.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/data/theme_mode_dao.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/widgets/theme_toggle_button.dart';

import '../helpers/pump_helpers.dart';

void main() {
  testWidgets(
      'cycle Système → Clair → Sombre → Système au tap, persisté en base',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final dao = ThemeModeDao(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ThemeToggleButton()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    await tester.runAsync(() async {
      expect(await dao.watchThemeMode().first, ThemeMode.light);
    });

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    await tester.runAsync(() async {
      expect(await dao.watchThemeMode().first, ThemeMode.dark);
    });

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    await tester.runAsync(() async {
      expect(await dao.watchThemeMode().first, ThemeMode.system);
    });

    await disposeWidgetTree(tester);
  });
}
