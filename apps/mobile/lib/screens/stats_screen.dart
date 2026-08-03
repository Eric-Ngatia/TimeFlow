import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Statistiques')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_StatsSegment>(
              segments: const [
                ButtonSegment(value: _StatsSegment.day, label: Text('Jour')),
                ButtonSegment(value: _StatsSegment.week, label: Text('Semaine')),
                ButtonSegment(value: _StatsSegment.month, label: Text('Mois')),
              ],
              selected: <_StatsSegment>{_segment},
              onSelectionChanged: (selection) => setState(() => _segment = selection.first),
            ),
          ),
          Expanded(
            child: switch (_segment) {
              _StatsSegment.day => const DayStatsView(),
              _StatsSegment.week => const WeekStatsView(),
              _StatsSegment.month => const MonthStatsView(),
            },
          ),
        ],
      ),
    );
  }
}
