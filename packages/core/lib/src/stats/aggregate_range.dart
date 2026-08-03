import 'package:timeflow_domain/timeflow_domain.dart';

import 'compute_day_stats.dart';

/// Combine des lignes déjà groupées par jour et par catégorie (issues du
/// DAO, `GROUP BY date, category` — RG-07) en [RangeStats].
///
/// Utilisée pour le bilan hebdomadaire (7 jours glissants) comme mensuel
/// (30 jours glissants) : la taille de la fenêtre est déterminée par
/// l'appelant (DAO) via les bornes de la requête SQL, cette fonction se
/// contente de combiner ce qu'on lui donne.
///
/// - [minutesByDateAndCategory] : pour chaque jour ayant au moins une
///   activité, la répartition des minutes par catégorie.
/// - [activitiesCountByDate] : nombre d'activités par jour (mêmes clés que
///   [minutesByDateAndCategory], ou sous-ensemble — défaut 0 si absent).
///
/// [RangeStats.daysTracked] compte les jours **effectivement suivis**
/// (présents dans [minutesByDateAndCategory]), pas la taille de la fenêtre
/// demandée — une fenêtre de 7 jours avec seulement 3 jours renseignés a
/// `daysTracked == 3`.
RangeStats aggregateRange({
  required Map<String, Map<CategoryId, int>> minutesByDateAndCategory,
  Map<String, int> activitiesCountByDate = const <String, int>{},
}) {
  final dates = minutesByDateAndCategory.keys.toList()..sort();

  final days = <DayStats>[
    for (final date in dates)
      computeDayStats(
        date: date,
        minutesByCategory: minutesByDateAndCategory[date]!,
        activitiesCount: activitiesCountByDate[date] ?? 0,
      ),
  ];

  return rangeStatsFromDays(days);
}

/// Combine une liste de [DayStats] **déjà calculés** (ex. un flux
/// `watchHistory` déjà groupé par jour côté DAO) en [RangeStats].
///
/// Complète [aggregateRange] pour les appelants qui ont déjà des
/// [DayStats] par jour plutôt que des lignes brutes groupées par
/// catégorie — évite de dupliquer le calcul de moyenne/total en dehors de
/// `packages/core` (ex. providers Riverpod alimentés par
/// `ActivityRepository.watchHistory`).
///
/// [days] n'a pas besoin d'être trié : le résultat ne dépend pas de
/// l'ordre d'entrée.
/// Fusionne les répartitions par catégorie de plusieurs [DayStats] (déjà
/// agrégés en SQL — RG-07) en une seule map minutes par catégorie sur toute
/// la plage.
///
/// Combinaison pure de valeurs déjà agrégées, pas une nouvelle règle
/// métier : utilisée pour le donut Semaine/Mois (RG-07).
///
/// Liste vide → map vide. Les catégories absentes d'un jour donné ne
/// contribuent simplement pas à la somme (pas d'entrée à 0 forcée).
Map<CategoryId, int> mergeByCategory(List<DayStats> days) {
  final merged = <CategoryId, int>{};
  for (final day in days) {
    for (final entry in day.byCategory.entries) {
      merged[entry.key] = (merged[entry.key] ?? 0) + entry.value;
    }
  }
  return merged;
}

RangeStats rangeStatsFromDays(List<DayStats> days) {
  final totalMin = days.fold<int>(0, (sum, day) => sum + day.totalMin);
  final daysTracked = days.length;
  final averageScore = daysTracked == 0
      ? 0.0
      : days.fold<int>(0, (sum, day) => sum + day.productivityScore) /
          daysTracked;

  return RangeStats(
    days: days,
    averageScore: averageScore,
    totalMin: totalMin,
    daysTracked: daysTracked,
  );
}
