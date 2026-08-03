import 'activity.dart';

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

int _mapHash<K, V>(Map<K, V> map) {
  var hash = 0;
  for (final entry in map.entries) {
    // XOR-based combination: ordre des entrées sans influence sur le hash.
    hash ^= Object.hash(entry.key, entry.value);
  }
  return hash;
}

/// Statistiques agrégées d'une seule journée.
///
/// Construite à partir d'un résultat **déjà agrégé en SQL** (RG-07) —
/// jamais en chargeant les activités brutes en mémoire.
class DayStats {
  DayStats({
    required this.date,
    required this.totalMin,
    required Map<CategoryId, int> byCategory,
    required this.productivityScore,
    required this.activitiesCount,
  }) : byCategory = Map.unmodifiable(byCategory);

  /// Jour concerné, `YYYY-MM-DD` (RG-05).
  final String date;

  /// Total de minutes suivies ce jour-là, toutes catégories confondues.
  final int totalMin;

  /// Répartition des minutes par catégorie.
  final Map<CategoryId, int> byCategory;

  /// Score de productivité (0..100), voir RG-06.
  final int productivityScore;

  /// Nombre d'activités enregistrées ce jour-là.
  final int activitiesCount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayStats &&
        other.date == date &&
        other.totalMin == totalMin &&
        other.productivityScore == productivityScore &&
        other.activitiesCount == activitiesCount &&
        _mapEquals(other.byCategory, byCategory);
  }

  @override
  int get hashCode => Object.hash(
        date,
        totalMin,
        productivityScore,
        activitiesCount,
        _mapHash(byCategory),
      );

  @override
  String toString() =>
      'DayStats(date: $date, totalMin: $totalMin, byCategory: $byCategory, '
      'productivityScore: $productivityScore, activitiesCount: $activitiesCount)';
}

/// Statistiques agrégées sur une plage de jours (7 glissants pour la
/// semaine, 30 glissants pour le mois — RG-07).
class RangeStats {
  RangeStats({
    required List<DayStats> days,
    required this.averageScore,
    required this.totalMin,
    required this.daysTracked,
  }) : days = List.unmodifiable(days);

  /// Une entrée par jour ayant au moins une activité dans la plage,
  /// triée par [DayStats.date] croissant.
  final List<DayStats> days;

  /// Moyenne des scores de productivité journaliers de [days].
  /// `0` si [daysTracked] est `0` (aucune division par zéro).
  final double averageScore;

  /// Total de minutes suivies sur toute la plage.
  final int totalMin;

  /// Nombre de jours effectivement suivis (avec au moins une activité)
  /// dans la plage demandée.
  final int daysTracked;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RangeStats) return false;
    if (other.averageScore != averageScore ||
        other.totalMin != totalMin ||
        other.daysTracked != daysTracked ||
        other.days.length != days.length) {
      return false;
    }
    for (var i = 0; i < days.length; i++) {
      if (other.days[i] != days[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(averageScore, totalMin, daysTracked, Object.hashAll(days));

  @override
  String toString() =>
      'RangeStats(days: ${days.length}, averageScore: $averageScore, '
      'totalMin: $totalMin, daysTracked: $daysTracked)';
}
