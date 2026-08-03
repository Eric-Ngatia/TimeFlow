/// Interface d'accès aux réglages persistés de l'application.
///
/// Implémentée par `apps/mobile/lib/data/settings_dao.dart` (drift, table
/// `Settings` clé/valeur). Pour le MVP, seul le seuil de productivité est
/// exposé (RG-06 étendu).
abstract class SettingsRepository {
  /// Flux du seuil de productivité courant (40..80), défaut 60.
  Stream<int> watchProductivityThreshold();

  /// Modifie le seuil de productivité persisté.
  Future<void> setProductivityThreshold(int value);
}
