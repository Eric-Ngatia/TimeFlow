import 'package:flutter/material.dart';

import 'database.dart';

/// Clé de stockage de la préférence de thème dans la table `Settings`
/// (clé/valeur, déjà utilisée par [SettingsDao] pour le seuil de
/// productivité).
const String themeModeKey = 'theme_mode';

/// Persistance de la préférence de thème (`ThemeMode`) sur la table
/// `Settings` existante.
///
/// Volontairement **hors** de `SettingsRepository` (`packages/domain`) :
/// `ThemeMode` est un type Flutter, et `domain`/`core` ne dépendent jamais
/// de `flutter` (règle d'architecture n°1) — cette préférence est une pure
/// affaire d'UI, sans règle métier associée.
class ThemeModeDao {
  ThemeModeDao(this._db);

  final AppDatabase _db;

  /// Flux de la préférence de thème courante, `ThemeMode.system` par défaut
  /// si absente ou si la valeur stockée est corrompue/inconnue.
  Stream<ThemeMode> watchThemeMode() {
    final query = _db.select(_db.settings)
      ..where((tbl) => tbl.key.equals(themeModeKey));
    return query.watchSingleOrNull().map((row) {
      final raw = row?.value;
      if (raw == null) return ThemeMode.system;
      try {
        return ThemeMode.values.byName(raw);
      } on ArgumentError {
        return ThemeMode.system;
      }
    });
  }

  /// Persiste [mode] comme préférence de thème courante.
  Future<void> setThemeMode(ThemeMode mode) {
    return _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: themeModeKey,
            value: mode.name,
          ),
        );
  }
}
