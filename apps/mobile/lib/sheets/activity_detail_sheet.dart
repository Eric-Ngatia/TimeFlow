import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../application/activities_provider.dart';
import '../theme/category_colors.dart';
import '../theme/design_tokens.dart';
import '../utils/format_duration.dart';
import 'new_activity_sheet.dart';

final DateFormat _timeFormat = DateFormat.Hm();

/// Ouvre la sheet de détail d'une activité (écran 7) : clôture (RG-03),
/// édition, suppression avec confirmation (RG-08).
Future<void> showActivityDetailSheet(BuildContext context, Activity activity) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ActivityDetailSheet(activity: activity),
  );
}

class ActivityDetailSheet extends ConsumerWidget {
  const ActivityDetailSheet({required this.activity, super.key});

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visual = categoryVisualFor(activity.category, Theme.of(context).brightness);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: visual.color.withValues(alpha: 0.15),
                child: Text(visual.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    _CategoryBadge(emoji: visual.emoji, label: visual.label, color: visual.color),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _InfoCard(label: 'Début', value: _timeFormat.format(activity.startTime)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  label: 'Fin',
                  value: activity.endTime == null ? 'en cours' : _timeFormat.format(activity.endTime!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  label: 'Durée',
                  value: activity.durationMin == null ? '—' : formatDurationLabel(activity.durationMin!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (activity.isInProgress) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _closeActivity(context, ref),
                child: const Text('Clôturer maintenant'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _edit(context),
              child: const Text('Modifier'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _delete(context, ref),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Supprimer'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _closeActivity(BuildContext context, WidgetRef ref) async {
    try {
      final closed = closeActivity(activity, DateTime.now());
      await ref.read(activityRepositoryProvider).save(closed);
      if (context.mounted) Navigator.of(context).pop();
    } on ActivityValidationException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _edit(BuildContext context) {
    Navigator.of(context).pop();
    showNewActivitySheet(context, existingActivity: activity);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer l'activité ?"),
        content: const Text('Cette action est définitive et ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(dialogContext).colorScheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(activityRepositoryProvider).delete(activity.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.emoji, required this.label, required this.color});

  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: textTheme.labelMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: textTheme.titleMedium),
        ],
      ),
    );
  }
}
