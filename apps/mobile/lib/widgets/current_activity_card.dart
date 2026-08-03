import 'package:flutter/material.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../theme/category_colors.dart';
import '../theme/design_tokens.dart';

/// Carte « activité en cours » (RG-03) avec un point pulsant animé.
class CurrentActivityCard extends StatefulWidget {
  const CurrentActivityCard({
    required this.activity,
    this.onTap,
    this.onClose,
    super.key,
  });

  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  State<CurrentActivityCard> createState() => _CurrentActivityCardState();
}

class _CurrentActivityCardState extends State<CurrentActivityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final visual = categoryVisualFor(widget.activity.category, Theme.of(context).brightness);
    final textTheme = Theme.of(context).textTheme;
    final elapsedMin = DateTime.now().difference(widget.activity.startTime).inMinutes;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: visual.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: visual.color, width: 2),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + _pulseController.value * 0.5;
                return Opacity(
                  opacity: 1 - _pulseController.value * 0.6,
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(shape: BoxShape.circle, color: visual.color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EN COURS',
                    style: textTheme.labelMedium?.copyWith(color: visual.color),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.activity.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text(
                    '$elapsedMin min · ${visual.label}',
                    style: textTheme.bodySmall?.copyWith(color: tokens.muted),
                  ),
                ],
              ),
            ),
            if (widget.onClose != null)
              TextButton(
                onPressed: widget.onClose,
                child: const Text('Clôturer'),
              ),
          ],
        ),
      ),
    );
  }
}
