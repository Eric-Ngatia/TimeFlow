import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../application/activities_provider.dart';
import '../application/stats_provider.dart';
import '../sheets/day_detail_sheet.dart';
import '../theme/category_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/animations/fade_slide_in.dart';
import '../widgets/category_chip.dart';
import '../widgets/history_day_item.dart';
import '../widgets/theme_toggle_button.dart';

/// Fenêtre d'historique affichée (90 jours glissants).
const int _historyWindowDays = 90;

/// Écran 5 — Historique : liste des jours (déjà agrégés en SQL, RG-07) +
/// filtre par catégorie scrollable horizontalement.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  CategoryId? _filter;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TimeFlowColors>()!;
    final brightness = Theme.of(context).brightness;
    final today = todayDateKey();
    final from = formatLocalDate(
        DateTime.now().subtract(const Duration(days: _historyWindowDays - 1)));
    final historyAsync = ref.watch(historyProvider((from: from, to: today)));

    return Scaffold(
      appBar: AppBar(
          title: const Text('Historique'),
          actions: const [ThemeToggleButton()]),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    emoji: '✦',
                    label: 'Tout',
                    // `color` reste requis par la signature mais est sans effet
                    // visuel en style `pill` (fond/texte/bordure pilotés par
                    // les tokens `accent`/`surface`/`border`, cf. CategoryChip).
                    color: tokens.accent,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                    style: CategoryChipStyle.pill,
                  ),
                ),
                for (final id in CategoryId.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      emoji: categoryVisualFor(id, brightness).emoji,
                      label: categoryVisualFor(id, brightness).label,
                      // Idem : sans effet visuel en style `pill`.
                      color: categoryVisualFor(id, brightness).color,
                      selected: _filter == id,
                      onTap: () => setState(() => _filter = id),
                      style: CategoryChipStyle.pill,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: historyAsync.when(
              data: (days) {
                final filter = _filter;
                final filtered = filter == null
                    ? days
                    : days
                        .where((day) => (day.byCategory[filter] ?? 0) > 0)
                        .toList();

                if (filtered.isEmpty) {
                  return FadeSlideIn(
                    child: Center(
                      child: Text('Aucune activité.',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  );
                }

                final sorted = List<DayStats>.of(filtered)
                  ..sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) => FadeSlideIn(
                    delay: Duration(milliseconds: 40 * index.clamp(0, 6)),
                    child: HistoryDayItem(
                      dayStats: sorted[index],
                      onTap: () => showDayDetailSheet(context, sorted[index]),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Erreur : $error')),
            ),
          ),
        ],
      ),
    );
  }
}
