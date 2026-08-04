import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../theme/category_colors.dart';
import '../theme/design_tokens.dart';
import 'animations/fade_slide_in.dart';

final DateFormat _timeFormat = DateFormat.Hm();

/// Timeline verticale des activités du jour (points reliés par une ligne),
/// utilisée par l'écran Aujourd'hui.
class Timeline extends StatelessWidget {
  const Timeline({required this.activities, this.onTapActivity, super.key});

  final List<Activity> activities;
  final ValueChanged<Activity>? onTapActivity;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              "Aucune activité aujourd'hui.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < activities.length; i++)
          FadeSlideIn(
            delay: Duration(milliseconds: 40 * i.clamp(0, 6)),
            child: _TimelineTile(
              activity: activities[i],
              isLast: i == activities.length - 1,
              onTap: onTapActivity == null ? null : () => onTapActivity!(activities[i]),
            ),
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.activity, required this.isLast, this.onTap});

  final Activity activity;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final visual = categoryVisualFor(activity.category, Theme.of(context).brightness);
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: visual.color),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: tokens.border)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Row(
                    children: [
                      Text(visual.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity.title, style: textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(_timeRangeLabel(activity), style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                      if (activity.durationMin != null)
                        Text('${activity.durationMin} min', style: textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeRangeLabel(Activity activity) {
    final start = _timeFormat.format(activity.startTime);
    if (activity.endTime == null) {
      return '$start · en cours';
    }
    return '$start – ${_timeFormat.format(activity.endTime!)}';
  }
}
