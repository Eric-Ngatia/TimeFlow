import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/data/database.dart';
import 'package:timeflow_mobile/data/settings_dao.dart';

void main() {
  late AppDatabase db;
  late SettingsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SettingsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('watchProductivityThreshold renvoie la valeur par défaut (60) si absente', () async {
    final value = await dao.watchProductivityThreshold().first;
    expect(value, ProductivityThreshold.defaultValue);
  });

  test('setProductivityThreshold persiste puis watchProductivityThreshold reflète le changement', () async {
    await dao.setProductivityThreshold(75);
    final value = await dao.watchProductivityThreshold().first;
    expect(value, 75);
  });

  test('setProductivityThreshold borne la valeur au maximum (RG-06 étendu)', () async {
    await dao.setProductivityThreshold(999);
    final value = await dao.watchProductivityThreshold().first;
    expect(value, ProductivityThreshold.max);
  });

  test('setProductivityThreshold borne la valeur au minimum (RG-06 étendu)', () async {
    await dao.setProductivityThreshold(0);
    final value = await dao.watchProductivityThreshold().first;
    expect(value, ProductivityThreshold.min);
  });
}
