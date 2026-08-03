import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../../application/stats_provider.dart';
import '../../utils/format_duration.dart';
import '../../widgets/charts/category_donut_chart.dart';
import '../../widgets/kpi_card.dart';

/// Écran 4 — vue Mois de l'écran Statistiques : donut mensuel + 3 cartes
/// KPI (score moyen, heures totales, jours suivis) — 30 derniers jours
/// glissants (RG-07).
class MonthStatsView extends ConsumerWidget {
  const MonthStatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(monthStatsProvider);

    return statsAsync.when(
      data: (stats) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CategoryDonutChart(minutesByCategory: _mergeByCategory(stats.days)),
          const SizedBox(height: 24),
          KpiCard(label: 'Score moyen', value: '${stats.averageScore.round()}%'),
          const SizedBox(height: 12),
          KpiCard(label: 'Heures totales', value: formatDurationLabel(stats.totalMin)),
          const SizedBox(height: 12),
          KpiCard(label: 'Jours suivis', value: '${stats.daysTracked}/30'),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
    );
  }

  /// Fusionne, pour l'affichage du donut uniquement, les répartitions par
  /// catégorie déjà calculées par jour (`core.computeDayStats`) — simple
  /// addition de valeurs déjà agrégées en SQL, pas une nouvelle règle
  /// métier.
  Map<CategoryId, int> _mergeByCategory(List<DayStats> days) {
    final merged = <CategoryId, int>{};
    for (final day in days) {
      day.byCategory.forEach((category, minutes) {
        merged.update(category, (value) => value + minutes, ifAbsent: () => minutes);
      });
    }
    return merged;
  }
}
