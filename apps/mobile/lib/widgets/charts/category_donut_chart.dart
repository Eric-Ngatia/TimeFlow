import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../../theme/category_colors.dart';

/// Donut de répartition du temps par catégorie (`fl_chart`), utilisé par
/// les vues Jour et Mois de l'écran Statistiques.
class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart(
      {required this.minutesByCategory, this.centerLabel, super.key});

  final Map<CategoryId, int> minutesByCategory;

  /// Widget optionnel affiché centré par-dessus le donut (ex. total de la
  /// journée dans la bottom sheet Historique). `null` par défaut : pur
  /// affichage, sans effet sur les vues existantes qui ne le fournissent
  /// pas.
  final Widget? centerLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final total = minutesByCategory.values.fold<int>(0, (sum, m) => sum + m);
    final entries =
        minutesByCategory.entries.where((e) => e.value > 0).toList();

    if (total <= 0) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text('Aucune donnée',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: <PieChartSectionData>[
                for (final entry in entries)
                  PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: categoryVisualFor(entry.key, brightness).color,
                    title: '',
                    radius: 28,
                  ),
              ],
            ),
          ),
          if (centerLabel != null) centerLabel!,
        ],
      ),
    );
  }
}
