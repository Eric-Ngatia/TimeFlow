import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../application/activities_provider.dart';
import '../dev/seeds.dart';
import '../sheets/activity_detail_sheet.dart';
import '../sheets/new_activity_sheet.dart';
import '../theme/motion_tokens.dart';
import '../widgets/current_activity_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/timeline.dart';

/// Écran 1 — Aujourd'hui : activité en cours (RG-03), chronologie du jour,
/// FAB pour créer une nouvelle activité.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(todayActivitiesProvider);
    final currentActivity = ref.watch(currentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aujourd'hui"),
        actions: [
          const ThemeToggleButton(),
          // Bouton de seed, uniquement en debug (kDebugMode) — permet de
          // visualiser timeline/graphiques/historique sans saisie
          // manuelle (`lib/dev/seeds.dart`), jamais présent en build release.
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'Générer des données de démo',
              onPressed: () => _seedDemoData(context, ref),
            ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AnimatedSwitcher(
              duration: MotionTokens.fast,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: currentActivity != null
                  ? Padding(
                      key: ValueKey(currentActivity.id),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: CurrentActivityCard(
                        activity: currentActivity,
                        onTap: () =>
                            showActivityDetailSheet(context, currentActivity),
                        onClose: () =>
                            _closeActivity(context, ref, currentActivity),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            Text('Chronologie',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Timeline(
              activities: activities,
              onTapActivity: (activity) =>
                  showActivityDetailSheet(context, activity),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewActivitySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _closeActivity(
      BuildContext context, WidgetRef ref, Activity activity) async {
    try {
      final closed = closeActivity(activity, DateTime.now());
      await ref.read(activityRepositoryProvider).save(closed);
    } on ActivityValidationException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _seedDemoData(BuildContext context, WidgetRef ref) async {
    await seedDemoData(ref.read(activityRepositoryProvider));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Données de démo ajoutées.')),
      );
    }
  }
}
