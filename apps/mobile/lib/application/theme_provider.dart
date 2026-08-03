import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_mode_dao.dart';
import 'activities_provider.dart';

/// Implémentation drift de la persistance de la préférence de thème.
///
/// Volontairement en dehors de `SettingsRepository`/`packages/domain` : voir
/// le commentaire de [ThemeModeDao].
final Provider<ThemeModeDao> themeModeDaoProvider = Provider<ThemeModeDao>(
  (ref) => ThemeModeDao(ref.watch(databaseProvider)),
  name: 'themeModeDaoProvider',
);

/// Préférence de thème courante (`ThemeMode.system` par défaut).
final StreamProvider<ThemeMode> themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => ref.watch(themeModeDaoProvider).watchThemeMode(),
  name: 'themeModeProvider',
);
