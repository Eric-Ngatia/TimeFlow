import 'package:timeflow_domain/timeflow_domain.dart';

import 'productivity_score.dart';

/// Construit un [DayStats] à partir d'un résultat **déjà agrégé en SQL**
/// (RG-06, RG-07) : [minutesByCategory] et [activitiesCount] viennent d'une
/// requête `GROUP BY` du DAO. Cette fonction ne charge jamais les
/// activités brutes — elle est pure et ne fait aucun accès disque.
DayStats computeDayStats({
  required String date,
  required Map<CategoryId, int> minutesByCategory,
  required int activitiesCount,
}) {
  final totalMin =
      minutesByCategory.values.fold<int>(0, (sum, minutes) => sum + minutes);

  return DayStats(
    date: date,
    totalMin: totalMin,
    byCategory: minutesByCategory,
    productivityScore: productivityScore(minutesByCategory),
    activitiesCount: activitiesCount,
  );
}
