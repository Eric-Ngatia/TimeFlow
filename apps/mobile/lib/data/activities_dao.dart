import 'package:drift/drift.dart';
import 'package:timeflow_core/timeflow_core.dart' as core;
import 'package:timeflow_domain/timeflow_domain.dart';

import 'database.dart';

/// Implémentation drift de [ActivityRepository].
///
/// Toutes les agrégations (RG-07) passent par des requêtes SQL groupées
/// (`SUM` + `GROUP BY`) — jamais par un chargement complet des activités en
/// mémoire (règle d'architecture #5).
class ActivitiesDao implements ActivityRepository {
  ActivitiesDao(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Activity>> watchByDate(String date) {
    final query = _db.select(_db.activities)
      ..where((tbl) => tbl.date.equals(date))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<DayStats>> watchHistory(String from, String to) {
    return _groupedMinutesQuery(from, to).watch().asyncMap((rows) async {
      final minutesByDateAndCategory = _minutesByDateAndCategory(rows);
      final activitiesCountByDate = await _countByDate(from, to);
      final range = core.aggregateRange(
        minutesByDateAndCategory: minutesByDateAndCategory,
        activitiesCountByDate: activitiesCountByDate,
      );
      return range.days;
    });
  }

  @override
  Future<void> save(Activity activity) {
    return _db.into(_db.activities).insertOnConflictUpdate(
          ActivitiesCompanion.insert(
            id: activity.id,
            title: activity.title,
            category: activity.category.name,
            startTime: activity.startTime.toIso8601String(),
            endTime: Value(activity.endTime?.toIso8601String()),
            durationMin: Value(activity.durationMin),
            date: activity.date,
            createdAt: activity.createdAt.toIso8601String(),
          ),
        );
  }

  @override
  Future<void> delete(String id) {
    return (_db.delete(_db.activities)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<RangeStats> aggregateRange(String from, String to) async {
    final rows = await _groupedMinutesQuery(from, to).get();
    final minutesByDateAndCategory = _minutesByDateAndCategory(rows);
    final activitiesCountByDate = await _countByDate(from, to);
    return core.aggregateRange(
      minutesByDateAndCategory: minutesByDateAndCategory,
      activitiesCountByDate: activitiesCountByDate,
    );
  }

  /// Total de minutes déjà enregistrées pour [date] (RG-04) — à consulter
  /// avant `core.validateDailyTotal` lors de la création d'une activité.
  Future<int> totalMinutesForDate(String date) async {
    final totalMin = _db.activities.durationMin.sum();
    final query = _db.selectOnly(_db.activities)
      ..addColumns([totalMin])
      ..where(_db.activities.date.equals(date));
    final row = await query.getSingleOrNull();
    return row?.read(totalMin) ?? 0;
  }

  JoinedSelectStatement<Activities, ActivityRow> _groupedMinutesQuery(
    String from,
    String to,
  ) {
    final totalMin = _db.activities.durationMin.sum();
    return _db.selectOnly(_db.activities)
      ..addColumns([_db.activities.date, _db.activities.category, totalMin])
      ..where(_db.activities.date.isBetweenValues(from, to))
      ..groupBy([_db.activities.date, _db.activities.category]);
  }

  Map<String, Map<CategoryId, int>> _minutesByDateAndCategory(List<TypedResult> rows) {
    final totalMin = _db.activities.durationMin.sum();
    final result = <String, Map<CategoryId, int>>{};
    for (final row in rows) {
      final date = row.read(_db.activities.date)!;
      final categoryName = row.read(_db.activities.category)!;
      final minutes = row.read(totalMin) ?? 0;
      result.putIfAbsent(date, () => <CategoryId, int>{})[CategoryId.values.byName(categoryName)] =
          minutes;
    }
    return result;
  }

  Future<Map<String, int>> _countByDate(String from, String to) async {
    final countExp = _db.activities.id.count();
    final query = _db.selectOnly(_db.activities)
      ..addColumns([_db.activities.date, countExp])
      ..where(_db.activities.date.isBetweenValues(from, to))
      ..groupBy([_db.activities.date]);
    final rows = await query.get();
    return <String, int>{
      for (final row in rows) row.read(_db.activities.date)!: row.read(countExp) ?? 0,
    };
  }

  Activity _toDomain(ActivityRow row) {
    return Activity(
      id: row.id,
      title: row.title,
      category: CategoryId.values.byName(row.category),
      startTime: DateTime.parse(row.startTime),
      endTime: row.endTime != null ? DateTime.parse(row.endTime!) : null,
      durationMin: row.durationMin,
      date: row.date,
      createdAt: DateTime.parse(row.createdAt),
    );
  }
}
