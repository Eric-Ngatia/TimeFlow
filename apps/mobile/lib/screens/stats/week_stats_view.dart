import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_core/timeflow_core.dart';

import '../../application/stats_provider.dart';
import '../../utils/format_duration.dart';
import '../../widgets/charts/category_legend.dart';
import '../../widgets/charts/weekly_bar_chart.dart';
import '../../widgets/kpi_card.dart';

/// Écran 3 — vue Semaine de l'écran Statistiques : bar chart des 7
/// derniers jours glissants (RG-07), score moyen, temps total.
class WeekStatsView extends ConsumerWidget {
  const WeekStatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weekStatsProvider);

    return statsAsync.when(
      data: (stats) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WeeklyBarChart(days: stats.days),
          const SizedBox(height: 12),
          CategoryLegend(
            minutesByCategory: mergeByCategory(stats.days),
            showPercentage: false,
          ),
          const SizedBox(height: 24),
          KpiCard(
              label: 'Score moyen', value: '${stats.averageScore.round()}%'),
          const SizedBox(height: 12),
          KpiCard(
              label: 'Temps total', value: formatDurationLabel(stats.totalMin)),
          const SizedBox(height: 12),
          KpiCard(label: 'Jours suivis', value: '${stats.daysTracked}/7'),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
    );
  }
}
