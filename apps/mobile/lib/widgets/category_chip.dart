import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Variante visuelle de [CategoryChip].
enum CategoryChipStyle {
  /// Comportement historique : fond/bordure/texte teintés par [CategoryChip.color].
  badge,

  /// Variante « pilule » (rayon 999) utilisée par les filtres de l'écran
  /// Historique : [CategoryChip.color] est ignoré pour le fond/texte/bordure,
  /// seul l'emoji reste affiché tel quel.
  pill,
}

/// Puce emoji + libellé, avec état sélectionné/non sélectionné. Utilisée
/// par la grille de catégories de `NewActivitySheet` et les filtres de
/// l'écran Historique (y compris le filtre « Tout », qui ne correspond à
/// aucune [CategoryId] réelle — d'où des paramètres primitifs plutôt qu'un
/// `CategoryVisual`).
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.emoji,
    required this.label,
    required this.color,
    required this.selected,
    this.onTap,
    this.style = CategoryChipStyle.badge,
    super.key,
  });

  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  /// Variante de rendu. Par défaut [CategoryChipStyle.badge] (comportement
  /// historique, teinté par [color]).
  final CategoryChipStyle style;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final borderRadius =
        BorderRadius.circular(style == CategoryChipStyle.pill ? 999 : 12);

    late final Color backgroundColor;
    late final Color? borderColor;
    late final double borderWidth;
    late final Color textColor;

    if (style == CategoryChipStyle.pill) {
      if (selected) {
        backgroundColor = tokens.accent;
        borderColor = null;
        borderWidth = 0;
        textColor = Colors.white;
      } else {
        backgroundColor = tokens.surface;
        borderColor = tokens.border;
        borderWidth = 1;
        textColor = tokens.text;
      }
    } else {
      backgroundColor =
          selected ? color.withValues(alpha: 0.15) : tokens.surface2;
      borderColor = selected ? color : tokens.border;
      borderWidth = selected ? 2 : 1;
      textColor = selected ? color : tokens.text;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: textTheme.titleSmall?.copyWith(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
