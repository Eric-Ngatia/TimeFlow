import 'package:drift/drift.dart';

/// Table des activités suivies par l'utilisateur.
///
/// Schéma exact de `.claude/docs/data-model.md`. Toute modification de ce
/// fichier nécessite de régénérer le code drift :
/// `dart run build_runner build --delete-conflicting-outputs`.
// `DataClassName` évite la collision entre la classe générée par drift
// (par défaut `Activity`, singulier de `Activities`) et `timeflow_domain`'s
// `Activity` — les deux types coexistent dans ce fichier/ses consommateurs.
@TableIndex(name: 'idx_activities_date', columns: {#date})
@DataClassName('ActivityRow')
class Activities extends Table {
  /// UUID v4 (package `uuid`).
  TextColumn get id => text()();

  /// Obligatoire — RG-01.
  TextColumn get title => text()();

  /// `CategoryId` stocké en TEXT (nom de l'enum).
  TextColumn get category => text()();

  /// ISO 8601 local.
  TextColumn get startTime => text()();

  /// `null` si l'activité est en cours — RG-03.
  TextColumn get endTime => text().nullable()();

  /// RG-04.
  IntColumn get durationMin => integer().nullable()();

  /// `YYYY-MM-DD`, indexé — RG-05.
  TextColumn get date => text()();

  /// ISO 8601 local.
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table de réglages clé/valeur (ex. seuil de productivité — RG-06 étendu).
///
/// Aucun écran de réglages dans ce lot : cette table prépare seulement le
/// stockage pour un futur écran Settings.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
