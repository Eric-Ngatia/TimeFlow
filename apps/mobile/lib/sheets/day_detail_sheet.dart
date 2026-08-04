import 'package:flutter/material.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../utils/date_format_fr.dart';
import '../utils/format_duration.dart';
import '../widgets/charts/category_donut_chart.dart';
import '../widgets/charts/category_legend.dart';
import '../widgets/score_badge.dart';

/// Ouvre la sheet de détail d'une journée depuis l'écran Historique :
/// en-tête (date + score, RG-05/RG-06), donut de répartition (total au
/// centre) et légende par catégorie.
Future<void> showDayDetailSheet(BuildContext context, DayStats dayStats) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => DayDetailSheet(dayStats: dayStats),
  );
}

class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({required this.dayStats, super.key});

  final DayStats dayStats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final date = DateTime.parse(dayStats.date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatWeekdayLabel(date),
                        style: textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(formatDayLabel(date), style: textTheme.headlineMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ScoreBadge(score: dayStats.productivityScore),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Largeur fixée explicitement : `CategoryDonutChart` ne fixe
              // que sa hauteur (pensé pour un parent Column/ListView qui
              // lui donne déjà une largeur bornée) ; dans un `Row`, un
              // enfant sans `Expanded` reçoit une largeur non bornée, ce
              // que `PieChart` ne supporte pas.
              SizedBox(
                width: 140,
                child: CategoryDonutChart(
                  minutesByCategory: dayStats.byCategory,
                  centerLabel: Text(
                    formatDurationLabel(dayStats.totalMin),
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child:
                      CategoryLegend(minutesByCategory: dayStats.byCategory)),
            ],
          ),
        ],
      ),
    );
  }
}
