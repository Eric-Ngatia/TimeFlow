import 'package:flutter/material.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../theme/category_colors.dart';
import '../theme/design_tokens.dart';
import '../utils/date_format_fr.dart';
import 'score_badge.dart';

/// Ligne d'un jour dans l'écran Historique : date, mini-barres de
/// répartition par catégorie proportionnelles, total et [ScoreBadge].
///
/// Alimentée par `historyProvider` (requête SQL déjà groupée par jour —
/// RG-07), jamais par un recalcul en mémoire.
class HistoryDayItem extends StatelessWidget {
  const HistoryDayItem({required this.dayStats, this.onTap, super.key});

  final DayStats dayStats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final date = DateTime.parse(dayStats.date);
    final hours = dayStats.totalMin ~/ 60;
    final minutes = dayStats.totalMin % 60;
    final activityLabel =
        dayStats.activitiesCount > 1 ? 'activités' : 'activité';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatDayLabel(date), style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _CategoryDots(byCategory: dayStats.byCategory),
                  const SizedBox(height: 8),
                  Text(
                    "${hours}h${minutes.toString().padLeft(2, '0')} · "
                    '${dayStats.activitiesCount} $activityLabel',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ScoreBadge(score: dayStats.productivityScore),
          ],
        ),
      ),
    );
  }
}

class _CategoryDots extends StatelessWidget {
  const _CategoryDots({required this.byCategory});

  final Map<CategoryId, int> byCategory;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final total = byCategory.values.fold<int>(0, (sum, m) => sum + m);
    final entries = byCategory.entries.where((e) => e.value > 0).toList();

    if (total <= 0) {
      return const SizedBox(height: 6);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: <Widget>[
          for (final entry in entries)
            Expanded(
              flex: entry.value,
              child: Container(
                height: 6,
                color: categoryVisualFor(entry.key, brightness).color,
              ),
            ),
        ],
      ),
    );
  }
}
