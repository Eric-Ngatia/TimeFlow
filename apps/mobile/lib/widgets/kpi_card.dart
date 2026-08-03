import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Carte KPI générique (libellé + valeur), utilisée par les 3 vues de
/// l'écran Statistiques (score, temps total, jours suivis, etc.).
class KpiCard extends StatelessWidget {
  const KpiCard({required this.label, required this.value, this.trailing, super.key});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: textTheme.labelMedium),
                const SizedBox(height: 6),
                Text(value, style: textTheme.headlineMedium),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
