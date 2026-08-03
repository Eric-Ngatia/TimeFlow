import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_core/timeflow_core.dart';

import '../../application/stats_provider.dart';
import '../../utils/format_duration.dart';
import '../../widgets/charts/category_donut_chart.dart';
import '../../widgets/charts/category_legend.dart';
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
      data: (stats) {
        final merged = mergeByCategory(stats.days);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CategoryDonutChart(minutesByCategory: merged),
            const SizedBox(height: 12),
            CategoryLegend(minutesByCategory: merged),
            const SizedBox(height: 24),
            KpiCard(
                label: 'Score moyen', value: '${stats.averageScore.round()}%'),
            const SizedBox(height: 12),
            KpiCard(
                label: 'Heures totales',
                value: formatDurationLabel(stats.totalMin)),
            const SizedBox(height: 12),
            KpiCard(label: 'Jours suivis', value: '${stats.daysTracked}/30'),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
    );
  }
}
