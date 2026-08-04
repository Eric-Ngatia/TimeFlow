import 'package:flutter/material.dart';

import '../theme/motion_tokens.dart';
import '../widgets/segmented_tab_bar.dart';
import '../widgets/theme_toggle_button.dart';
import 'stats/day_stats_view.dart';
import 'stats/month_stats_view.dart';
import 'stats/week_stats_view.dart';

/// Écran hôte de l'onglet Statistiques : un seul écran avec sélecteur
/// interne Jour / Semaine / Mois (voir Risque #3 du plan) plutôt que 3
/// destinations top-level séparées.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

enum _StatsSegment { day, week, month }

class _StatsScreenState extends State<StatsScreen> {
  _StatsSegment _segment = _StatsSegment.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Statistiques'),
          actions: const [ThemeToggleButton()]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedTabBar<_StatsSegment>(
              segments: const [
                SegmentedTabBarItem(value: _StatsSegment.day, label: 'Jour'),
                SegmentedTabBarItem(
                    value: _StatsSegment.week, label: 'Semaine'),
                SegmentedTabBarItem(value: _StatsSegment.month, label: 'Mois'),
              ],
              selected: _segment,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: MotionTokens.fast,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: KeyedSubtree(
                key: ValueKey(_segment),
                child: switch (_segment) {
                  _StatsSegment.day => const DayStatsView(),
                  _StatsSegment.week => const WeekStatsView(),
                  _StatsSegment.month => const MonthStatsView(),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
