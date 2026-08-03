import 'package:timeflow_domain/timeflow_domain.dart';

import 'database.dart';

/// Clé de stockage du seuil de productivité (RG-06 étendu) dans la table
/// `Settings` (clé/valeur).
const String productivityThresholdKey = 'productivity_threshold';

/// Implémentation drift de [SettingsRepository] sur la table `Settings`.
class SettingsDao implements SettingsRepository {
  SettingsDao(this._db);

  final AppDatabase _db;

  @override
  Stream<int> watchProductivityThreshold() {
    final query = _db.select(_db.settings)
      ..where((tbl) => tbl.key.equals(productivityThresholdKey));
    return query.watchSingleOrNull().map((row) {
      final raw = row?.value;
      return raw != null
          ? ProductivityThreshold(int.parse(raw)).value
          : ProductivityThreshold.defaultValue;
    });
  }

  @override
  Future<void> setProductivityThreshold(int value) {
    final clamped = ProductivityThreshold(value).value;
    return _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: productivityThresholdKey,
            value: clamped.toString(),
          ),
        );
  }
}
