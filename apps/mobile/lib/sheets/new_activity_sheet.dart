import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:uuid/uuid.dart';

import '../application/activities_provider.dart';
import '../theme/category_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/category_chip.dart';

/// Ouvre la sheet de création/édition d'activité.
///
/// - RG-01, RG-02 : validation via `core.validateActivity`.
/// - RG-03 : heure de fin optionnelle (« en cours… »).
/// - RG-04 : total journalier vérifié via `core.validateDailyTotal` avant
///   l'enregistrement.
/// - Risque #7 du plan : réutilisée en mode édition ([existingActivity])
///   pour éviter de dupliquer la logique de validation.
Future<void> showNewActivitySheet(BuildContext context, {Activity? existingActivity}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => NewActivitySheet(existingActivity: existingActivity),
  );
}

class NewActivitySheet extends ConsumerStatefulWidget {
  const NewActivitySheet({this.existingActivity, super.key});

  final Activity? existingActivity;

  @override
  ConsumerState<NewActivitySheet> createState() => _NewActivitySheetState();
}

class _NewActivitySheetState extends ConsumerState<NewActivitySheet> {
  late final TextEditingController _titleController;
  CategoryId? _category;
  late DateTime _startTime;
  DateTime? _endTime;
  late bool _inProgress;
  ValidationResult _validation = const ValidationResult();
  String? _dailyTotalError;
  bool _saving = false;

  bool get _isEditing => widget.existingActivity != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingActivity;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _category = existing?.category;
    _startTime = existing?.startTime ?? DateTime.now();
    _endTime = existing?.endTime;
    _inProgress = existing == null ? true : existing.isInProgress;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final base = isStart ? _startTime : (_endTime ?? DateTime.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final result = DateTime(
        _startTime.year,
        _startTime.month,
        _startTime.day,
        picked.hour,
        picked.minute,
      );
      if (isStart) {
        _startTime = result;
      } else {
        _endTime = result;
      }
    });
  }

  Future<void> _save() async {
    final title = _titleController.text;
    final effectiveEndTime = _inProgress ? null : _endTime;

    final validation = validateActivity(
      title: title,
      category: _category,
      startTime: _startTime,
      endTime: effectiveEndTime,
    );
    setState(() {
      _validation = validation;
      _dailyTotalError = null;
    });
    if (!validation.isValid) return;

    setState(() => _saving = true);

    try {
      final repo = ref.read(activityRepositoryProvider);
      final date = formatLocalDate(_startTime);
      final durationMin =
          effectiveEndTime != null ? computeDurationMin(_startTime, effectiveEndTime) : 0;

      if (durationMin > 0) {
        final dayRange = await repo.aggregateRange(date, date);
        final existingTotal = dayRange.days.isEmpty ? 0 : dayRange.days.first.totalMin;
        final previousOwnDuration =
            (_isEditing && widget.existingActivity!.date == date)
                ? (widget.existingActivity!.durationMin ?? 0)
                : 0;
        validateDailyTotal(existingTotal - previousOwnDuration, durationMin);
      }

      final activity = createActivity(
        id: widget.existingActivity?.id ?? const Uuid().v4(),
        title: title,
        category: _category!,
        startTime: _startTime,
        endTime: effectiveEndTime,
        createdAt: widget.existingActivity?.createdAt,
      );

      await repo.save(activity);
      if (mounted) Navigator.of(context).pop();
    } on DailyTotalExceededException {
      setState(() {
        _dailyTotalError = 'Le total journalier dépasserait 24h (1440 min).';
      });
    } on ActivityValidationException catch (e) {
      setState(() => _validation = e.result);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEditing ? "Modifier l'activité" : 'Nouvelle activité',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              decoration: InputDecoration(
                labelText: 'Titre',
                errorText: _validation.errorFor(ValidationField.title),
              ),
            ),
            const SizedBox(height: 16),
            Text('Catégorie'.toUpperCase(), style: textTheme.labelMedium),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: [
                for (final id in CategoryId.values)
                  CategoryChip(
                    emoji: categoryVisualFor(id, brightness).emoji,
                    label: categoryVisualFor(id, brightness).label,
                    color: categoryVisualFor(id, brightness).color,
                    selected: _category == id,
                    onTap: () => setState(() => _category = id),
                  ),
              ],
            ),
            if (_validation.errorFor(ValidationField.category) != null) ...[
              const SizedBox(height: 6),
              Text(
                _validation.errorFor(ValidationField.category)!,
                style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Début',
                    time: _startTime,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _inProgress
                      ? _InProgressField(onTap: () => setState(() => _inProgress = false))
                      : _TimeField(
                          label: 'Fin',
                          time: _endTime,
                          onTap: () => _pickTime(isStart: false),
                        ),
                ),
              ],
            ),
            if (!_inProgress)
              TextButton(
                onPressed: () => setState(() {
                  _inProgress = true;
                  _endTime = null;
                }),
                child: const Text('Marquer comme en cours'),
              ),
            if (_validation.errorFor(ValidationField.timeRange) != null) ...[
              const SizedBox(height: 6),
              Text(
                _validation.errorFor(ValidationField.timeRange)!,
                style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_dailyTotalError != null) ...[
              const SizedBox(height: 6),
              Text(
                _dailyTotalError!,
                style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: tokens.accent),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.time, required this.onTap});

  final String label;
  final DateTime? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final formatted = time == null
        ? '--:--'
        : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: textTheme.labelSmall),
            const SizedBox(height: 2),
            Text(formatted, style: textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _InProgressField extends StatelessWidget {
  const _InProgressField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FIN'.toUpperCase(), style: textTheme.labelSmall),
            const SizedBox(height: 2),
            Text('en cours…', style: textTheme.titleMedium?.copyWith(color: tokens.accent)),
          ],
        ),
      ),
    );
  }
}
