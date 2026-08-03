import 'package:flutter/material.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

/// Badge coloré affichant le score de productivité (RG-06) et son palier
/// (Productive/Correcte/Peu productive), calculé exclusivement via
/// `core.productivityLevel` — jamais recalculé ici.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    required this.score,
    this.threshold = ProductivityThreshold.defaultValue,
    super.key,
  });

  /// Score de productivité (0..100), déjà calculé par `packages/core`.
  final int score;

  /// Seuil de productivité courant (RG-06 étendu), défaut
  /// [ProductivityThreshold.defaultValue].
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final level = productivityLevel(score, threshold: threshold);
    final (label, color) = switch (level) {
      ProductivityLevel.productive => ('Productive', const Color(0xFF4C8C5A)),
      ProductivityLevel.correct => ('Correcte', const Color(0xFFB5632B)),
      ProductivityLevel.low => ('Peu productive', const Color(0xFFC24E6E)),
    };
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$score%', style: textTheme.labelLarge?.copyWith(color: color)),
          const SizedBox(width: 6),
          Text(label, style: textTheme.labelMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}
