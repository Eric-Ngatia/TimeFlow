import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/activities_provider.dart';
import '../../application/stats_provider.dart';
import '../../utils/format_duration.dart';
import '../../widgets/charts/category_donut_chart.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/score_badge.dart';

/// Écran 2 — vue Jour de l'écran Statistiques : donut de répartition,
/// score de productivité (RG-06), temps de travail total.
class DayStatsView extends ConsumerWidget {
  const DayStatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dayStatsProvider(todayDateKey()));

    return statsAsync.when(
      data: (stats) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CategoryDonutChart(minutesByCategory: stats.byCategory),
          const SizedBox(height: 24),
          KpiCard(
            label: 'Score de productivité',
            value: '${stats.productivityScore}%',
            trailing: ScoreBadge(score: stats.productivityScore),
          ),
          const SizedBox(height: 12),
          KpiCard(label: 'Temps de travail total', value: formatDurationLabel(stats.totalMin)),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
    );
  }
}
