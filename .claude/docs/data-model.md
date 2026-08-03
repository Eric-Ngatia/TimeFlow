# Modèle de données TimeFlow (référence)

## Table SQL `activities` (drift)

```dart
// apps/mobile/lib/data/tables.dart
class Activities extends Table {
  TextColumn get id => text()();                          // UUID v4 (package uuid)
  TextColumn get title => text()();                        // obligatoire — RG-01
  TextColumn get category => text()();                      // enum CategoryId (stocké en TEXT)
  TextColumn get startTime => text()();                     // ISO 8601 local
  TextColumn get endTime => text().nullable()();            // null si en cours — RG-03
  IntColumn get durationMin => integer().nullable()();      // RG-04
  TextColumn get date => text()();                          // YYYY-MM-DD, indexé — RG-05
  TextColumn get createdAt => text()();                     // ISO 8601

  @override
  Set<Column> get primaryKey => {id};
}
```

Index recommandé : `CREATE INDEX idx_activities_date ON activities(date);`

## CategoryId (enum Dart, `packages/domain`)
work 💼 · sport 🏃 · leisure 🎮 · sleep 😴 · social 💬 · other 📦

## DayStats (calculé en Dart depuis une requête agrégée — jamais stocké, RG-07)
- `date`: String (YYYY-MM-DD)
- `totalMin`: int
- `byCategory`: Map<CategoryId, int>
- `productivityScore`: int (0..100, RG-06)
- `activitiesCount`: int

## Requête type — bilan hebdomadaire (RG-07)

```sql
SELECT date, category, SUM(duration_min) AS total
FROM activities
WHERE date >= :sevenDaysAgo
GROUP BY date, category;
```

En drift, cette requête s'écrit typée dans `ActivitiesDao` (méthode `aggregateRange`), pas en Dart après un `SELECT *`.

## Table `settings` (optionnelle, clé/valeur pour préférences simples)
- `key`: TEXT PRIMARY KEY
- `value`: TEXT
