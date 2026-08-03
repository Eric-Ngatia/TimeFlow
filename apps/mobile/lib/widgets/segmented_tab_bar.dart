import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Un segment de [SegmentedTabBar].
///
/// Classe dédiée (plutôt qu'un record) pour éviter tout souci de lint et
/// garder une API explicite `value`/`label`.
@immutable
class SegmentedTabBarItem<T> {
  const SegmentedTabBarItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// Sélecteur segmenté générique (ex. Jour/Semaine/Mois), sur le modèle
/// visuel de [CategoryChip] (`Row` + `AnimatedContainer`, pas de dépendance
/// à `SegmentedButton` Material qui teinte le segment actif avec `accent`
/// sans permettre de retrait propre de cette teinte).
///
/// Rendu : conteneur externe `tokens.surface2`, rayon 12, padding 4 ; chaque
/// segment est un `Expanded` avec `AnimatedContainer` — actif : fond
/// `tokens.surface` + ombre `tokens.shadow`, texte `tokens.text` ; inactif :
/// fond transparent, texte `tokens.muted` (aucune teinte `accent`).
class SegmentedTabBar<T> extends StatelessWidget {
  const SegmentedTabBar(
      {required this.segments,
      required this.selected,
      required this.onChanged,
      super.key});

  final List<SegmentedTabBarItem<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: tokens.surface2, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(segment.value),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: segment.value == selected
                        ? tokens.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: segment.value == selected
                        ? [
                            BoxShadow(
                                color: tokens.shadow,
                                blurRadius: 3,
                                offset: const Offset(0, 1))
                          ]
                        : null,
                  ),
                  child: Text(
                    segment.label,
                    style: textTheme.titleSmall?.copyWith(
                      color: segment.value == selected
                          ? tokens.text
                          : tokens.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
