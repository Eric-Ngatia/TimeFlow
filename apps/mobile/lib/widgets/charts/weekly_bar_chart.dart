import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../../theme/design_tokens.dart';

const List<String> _weekdayLabelsFr = <String>['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

/// Bar chart des 7 derniers jours glissants (RG-07), une barre par jour,
/// pour la vue Semaine de l'écran Statistiques.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({required this.days, super.key});

  /// Un [DayStats] par jour de la fenêtre, trié par date croissante.
  final List<DayStats> days;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;

    if (days.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Aucune donnée', style: textTheme.bodyMedium)),
      );
    }

    final maxMinutes = days.fold<int>(0, (max, d) => d.totalMin > max ? d.totalMin : max);
    final safeMax = maxMinutes == 0 ? 60.0 : maxMinutes.toDouble();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: safeMax * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) return const SizedBox.shrink();
                  final date = DateTime.parse(days[index].date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _weekdayLabelsFr[date.weekday - 1],
                      style: textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: <BarChartGroupData>[
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: days[i].totalMin.toDouble(),
                    color: tokens.accent,
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
