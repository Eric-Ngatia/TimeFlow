import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/data/theme_mode_dao.dart';

void main() {
  late AppDatabase db;
  late ThemeModeDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = ThemeModeDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('watchThemeMode renvoie ThemeMode.system par défaut si absent',
      () async {
    final mode = await dao.watchThemeMode().first;
    expect(mode, ThemeMode.system);
  });

  test('setThemeMode(light) persiste puis watchThemeMode reflète le changement',
      () async {
    await dao.setThemeMode(ThemeMode.light);
    final mode = await dao.watchThemeMode().first;
    expect(mode, ThemeMode.light);
  });

  test('setThemeMode(dark) persiste puis watchThemeMode reflète le changement',
      () async {
    await dao.setThemeMode(ThemeMode.dark);
    final mode = await dao.watchThemeMode().first;
    expect(mode, ThemeMode.dark);
  });

  test('setThemeMode(system) après un autre mode revient à ThemeMode.system',
      () async {
    await dao.setThemeMode(ThemeMode.dark);
    await dao.setThemeMode(ThemeMode.system);
    final mode = await dao.watchThemeMode().first;
    expect(mode, ThemeMode.system);
  });

  test(
      'valeur stockée corrompue/inconnue replie sur ThemeMode.system sans exception',
      () async {
    await db.into(db.settings).insertOnConflictUpdate(
          const SettingsCompanion(
            key: Value(themeModeKey),
            value: Value('not_a_theme_mode'),
          ),
        );
    final mode = await dao.watchThemeMode().first;
    expect(mode, ThemeMode.system);
  });
}
