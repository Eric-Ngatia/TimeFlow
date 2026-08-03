import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/theme_provider.dart';

/// Cycle Système → Clair → Sombre → Système.
const List<ThemeMode> _themeModeCycle = <ThemeMode>[
  ThemeMode.system,
  ThemeMode.light,
  ThemeMode.dark,
];

/// Bouton de bascule du thème (Système/Clair/Sombre), partagé par les 3
/// écrans principaux (Aujourd'hui/Statistiques/Historique) — seul point de
/// logique pour éviter toute duplication.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return IconButton(
      icon: Icon(_iconFor(mode)),
      tooltip: 'Thème : ${_labelFor(mode)}',
      onPressed: () => _cycle(ref, mode),
    );
  }

  IconData _iconFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };

  String _labelFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'Système',
        ThemeMode.light => 'Clair',
        ThemeMode.dark => 'Sombre',
      };

  void _cycle(WidgetRef ref, ThemeMode current) {
    final currentIndex = _themeModeCycle.indexOf(current);
    final next = _themeModeCycle[(currentIndex + 1) % _themeModeCycle.length];
    ref.read(themeModeDaoProvider).setThemeMode(next);
  }
}
