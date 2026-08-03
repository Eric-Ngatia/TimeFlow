import 'activity.dart';
import 'day_stats.dart';

/// Interface d'accès aux activités.
///
/// Implémentée par `apps/mobile/lib/data/activities_dao.dart` (drift).
/// `packages/core` reçoit cette interface par injection — il n'accède
/// jamais directement à une base de données.
abstract class ActivityRepository {
  /// Flux des activités du jour [date] (`YYYY-MM-DD`), le plus récent en
  /// premier. Filtré en base (`WHERE date = ?`) — RG-05.
  Stream<List<Activity>> watchByDate(String date);

  /// Flux de l'historique entre [from] et [to] (`YYYY-MM-DD` inclus),
  /// déjà groupé par jour et par catégorie côté requête — une entrée
  /// [DayStats] par jour ayant au moins une activité. Alimente l'écran
  /// Historique sans jamais charger les activités brutes (RG-07).
  Stream<List<DayStats>> watchHistory(String from, String to);

  /// Enregistre (création ou mise à jour) une activité.
  Future<void> save(Activity activity);

  /// Supprime définitivement l'activité [id] (RG-08).
  Future<void> delete(String id);

  /// Agrège les activités entre [from] et [to] (`YYYY-MM-DD` inclus) via une
  /// requête SQL groupée (`SUM` + `GROUP BY date, category`) — jamais de
  /// pré-calcul stocké (RG-07).
  Future<RangeStats> aggregateRange(String from, String to);
}
