import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

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
    super.key,
  });

  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : tokens.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : tokens.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: selected ? color : tokens.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
