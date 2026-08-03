import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import 'activities_provider.dart';

/// Statistiques d'un seul jour (`YYYY-MM-DD`), pour l'onglet « Jour » de
/// l'écran Statistiques (RG-06).
///
/// Basé sur `ActivityRepository.watchHistory` (requête SQL groupée,
/// réactive) plutôt qu'un chargement des activités brutes.
final AutoDisposeStreamProviderFamily<DayStats, String> dayStatsProvider =
    StreamProvider.autoDispose.family<DayStats, String>((ref, date) {
  return ref.watch(activityRepositoryProvider).watchHistory(date, date).map(
        (days) => days.isEmpty
            ? computeDayStats(date: date, minutesByCategory: const {}, activitiesCount: 0)
            : days.first,
      );
});

/// Borne inférieure (`YYYY-MM-DD`) d'une fenêtre glissante de [days] jours
/// se terminant aujourd'hui (bornes incluses) — RG-07.
String _slidingWindowStart(int days) {
  final start = DateTime.now().subtract(Duration(days: days - 1));
  return formatLocalDate(start);
}

/// Bilan hebdomadaire : 7 derniers jours glissants (RG-07), pour l'onglet
/// « Semaine » de l'écran Statistiques.
final AutoDisposeStreamProvider<RangeStats> weekStatsProvider = StreamProvider.autoDispose<RangeStats>((ref) {
  final today = todayDateKey();
  final from = _slidingWindowStart(7);
  return ref
      .watch(activityRepositoryProvider)
      .watchHistory(from, today)
      .map(rangeStatsFromDays);
});

/// Bilan mensuel : 30 derniers jours glissants (RG-07), pour l'onglet
/// « Mois » de l'écran Statistiques.
final AutoDisposeStreamProvider<RangeStats> monthStatsProvider = StreamProvider.autoDispose<RangeStats>((ref) {
  final today = todayDateKey();
  final from = _slidingWindowStart(30);
  return ref
      .watch(activityRepositoryProvider)
      .watchHistory(from, today)
      .map(rangeStatsFromDays);
});

/// Plage de dates (`YYYY-MM-DD` inclus) demandée à [historyProvider].
typedef DateRange = ({String from, String to});

/// Historique complet groupé par jour (écran Historique), déjà agrégé côté
/// requête (RG-07) — jamais de chargement des activités brutes.
final AutoDisposeStreamProviderFamily<List<DayStats>, DateRange> historyProvider =
    StreamProvider.autoDispose.family<List<DayStats>, DateRange>((ref, range) {
  return ref.watch(activityRepositoryProvider).watchHistory(range.from, range.to);
});
