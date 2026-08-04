import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../../theme/category_colors.dart';
import '../../theme/motion_tokens.dart';

/// Donut de répartition du temps par catégorie (`fl_chart`), utilisé par
/// les vues Jour et Mois de l'écran Statistiques.
///
/// À l'ouverture, les sections se révèlent en balayage horaire séquentiel
/// (la catégorie N se remplit entièrement avant que N+1 ne commence),
/// animation one-shot jouée une seule fois au montage du widget (pas de
/// rejeu sur mise à jour des données).
class CategoryDonutChart extends StatefulWidget {
  const CategoryDonutChart(
      {required this.minutesByCategory, this.centerLabel, super.key});

  final Map<CategoryId, int> minutesByCategory;

  /// Widget optionnel affiché centré par-dessus le donut (ex. total de la
  /// journée dans la bottom sheet Historique). `null` par défaut : pur
  /// affichage, sans effet sur les vues existantes qui ne le fournissent
  /// pas.
  final Widget? centerLabel;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.chartEntrance,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final minutesByCategory = widget.minutesByCategory;
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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final revealed = _controller.value * total;
              final sections = <PieChartSectionData>[];
              var cumulativeBefore = 0.0;
              for (final entry in entries) {
                final finalValue = entry.value.toDouble();
                final animatedValue =
                    (revealed - cumulativeBefore).clamp(0.0, finalValue);
                if (animatedValue > 0) {
                  sections.add(
                    PieChartSectionData(
                      value: animatedValue,
                      color: categoryVisualFor(entry.key, brightness).color,
                      title: '',
                      radius: 28,
                    ),
                  );
                }
                cumulativeBefore += finalValue;
              }
              return PieChart(
                swapAnimationDuration: Duration.zero,
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 48,
                  sections: sections,
                ),
              );
            },
          ),
          if (widget.centerLabel != null) widget.centerLabel!,
        ],
      ),
    );
  }
}
