import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/theme_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TimeFlowApp()));
}

class TimeFlowApp extends ConsumerWidget {
  const TimeFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `.valueOrNull ?? ThemeMode.system` : le flux drift démarre en
    // `AsyncLoading` (base `LazyDatabase`) — repli sur système le temps du
    // premier chargement pour éviter tout flash/crash au premier frame.
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'TimeFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
