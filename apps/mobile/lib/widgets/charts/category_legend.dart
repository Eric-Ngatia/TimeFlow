import 'package:flutter/material.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../../theme/category_colors.dart';
import '../../utils/format_duration.dart';

/// Légende d'une répartition de minutes par catégorie : une ligne par
/// catégorie non vide (pastille couleur, libellé, durée et — optionnellement
/// — pourcentage), triée par minutes décroissantes.
///
/// Pur affichage sur des données déjà agrégées (SQL / `packages/core`) :
/// le pourcentage `minutes catégorie / total * 100` n'est pas une règle
/// métier (à distinguer de RG-06, qui porte spécifiquement sur `work/total`).
class CategoryLegend extends StatelessWidget {
  const CategoryLegend(
      {required this.minutesByCategory, this.showPercentage = true, super.key});

  final Map<CategoryId, int> minutesByCategory;

  /// Affiche ou non le pourcentage à droite de la durée. `true` par défaut
  /// (Jour/Mois/Historique) ; mis à `false` pour la vue Semaine.
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final total = minutesByCategory.values.fold<int>(0, (sum, m) => sum + m);

    if (total <= 0) {
      return const SizedBox.shrink();
    }

    final brightness = Theme.of(context).brightness;
    final textTheme = Theme.of(context).textTheme;
    final entries = minutesByCategory.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: categoryVisualFor(entry.key, brightness).color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoryVisualFor(entry.key, brightness).label,
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(formatDurationLabel(entry.value),
                    style: textTheme.bodyMedium),
                if (showPercentage) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${(entry.value / total * 100).round()}%',
                      textAlign: TextAlign.end,
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
