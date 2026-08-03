import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:timeflow_mobile/data/activities_dao.dart';
import 'package:timeflow_mobile/data/database.dart';

void main() {
  late AppDatabase db;
  late ActivitiesDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = ActivitiesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test("save puis watchByDate renvoie l'activité sauvegardée", () async {
    final start = DateTime(2026, 8, 1, 9);
    final activity = createActivity(
      id: 'a1',
      title: 'Réunion',
      category: CategoryId.work,
      startTime: start,
      endTime: start.add(const Duration(minutes: 60)),
    );
    await dao.save(activity);

    final result = await dao.watchByDate('2026-08-01').first;
    expect(result, hasLength(1));
    expect(result.first.id, 'a1');
    expect(result.first.durationMin, 60);
  });

  test('watchByDate filtre en base (WHERE date = ?), pas en mémoire (RG-05)', () async {
    await dao.save(createActivity(
      id: 'a1',
      title: 'Jour 1',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 1, 9),
      endTime: DateTime(2026, 8, 1, 10),
    ));
    await dao.save(createActivity(
      id: 'a2',
      title: 'Jour 2',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 2, 9),
      endTime: DateTime(2026, 8, 2, 10),
    ));

    final day1 = await dao.watchByDate('2026-08-01').first;
    expect(day1.map((a) => a.id), <String>['a1']);
  });

  test("save avec le même id met à jour l'activité existante (RG-08)", () async {
    final activity = createActivity(
      id: 'a1',
      title: 'Titre initial',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 1, 9),
    );
    await dao.save(activity);
    await dao.save(activity.copyWith(title: 'Titre modifié'));

    final result = await dao.watchByDate('2026-08-01').first;
    expect(result, hasLength(1));
    expect(result.first.title, 'Titre modifié');
  });

  test('delete supprime définitivement (RG-08)', () async {
    await dao.save(createActivity(
      id: 'a1',
      title: 'À supprimer',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 1, 9),
    ));
    await dao.delete('a1');

    final result = await dao.watchByDate('2026-08-01').first;
    expect(result, isEmpty);
  });

  test('aggregateRange agrège via SQL (SUM + GROUP BY) sur une plage (RG-07)', () async {
    await dao.save(createActivity(
      id: 'a1',
      title: 'Travail',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 1, 9),
      endTime: DateTime(2026, 8, 1, 11),
    ));
    await dao.save(createActivity(
      id: 'a2',
      title: 'Sport',
      category: CategoryId.sport,
      startTime: DateTime(2026, 8, 1, 18),
      endTime: DateTime(2026, 8, 1, 19),
    ));
    await dao.save(createActivity(
      id: 'a3',
      title: 'Autre jour',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 5, 9),
      endTime: DateTime(2026, 8, 5, 10),
    ));

    final range = await dao.aggregateRange('2026-08-01', '2026-08-01');
    expect(range.daysTracked, 1);
    expect(range.days.single.totalMin, 180);
    expect(range.days.single.byCategory[CategoryId.work], 120);
    expect(range.days.single.byCategory[CategoryId.sport], 60);
  });

  test('watchHistory renvoie des jours déjà groupés par catégorie (RG-07)', () async {
    await dao.save(createActivity(
      id: 'a1',
      title: 'Travail J1',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 1, 9),
      endTime: DateTime(2026, 8, 1, 10),
    ));
    await dao.save(createActivity(
      id: 'a2',
      title: 'Travail J2',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 2, 9),
      endTime: DateTime(2026, 8, 2, 10),
    ));

    final history = await dao.watchHistory('2026-08-01', '2026-08-02').first;
    expect(history.map((d) => d.date), <String>['2026-08-01', '2026-08-02']);
  });

  test('totalMinutesForDate renvoie 0 sans activité', () async {
    final total = await dao.totalMinutesForDate('2026-08-01');
    expect(total, 0);
  });

  test("une activité en cours (endTime null) compte pour 0 minute dans l'agrégation (RG-03/04)", () async {
    await dao.save(createActivity(
      id: 'a1',
      title: 'En cours',
      category: CategoryId.work,
      startTime: DateTime(2026, 8, 1, 9),
    ));

    final range = await dao.aggregateRange('2026-08-01', '2026-08-01');
    expect(range.days.single.totalMin, 0);
  });
}
