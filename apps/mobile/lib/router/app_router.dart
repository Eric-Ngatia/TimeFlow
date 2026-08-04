import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/history_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/today_screen.dart';
import '../theme/motion_tokens.dart';

/// Routes des 3 onglets principaux (`ShellRoute`).
///
/// Les bottom sheets (`NewActivitySheet`, `ActivityDetailSheet`) ne sont
/// pas des routes go_router : elles s'ouvrent via `showModalBottomSheet`
/// depuis les écrans qui les déclenchent (FAB, tap sur une activité).
class AppRoutes {
  const AppRoutes._();

  static const String today = '/today';
  static const String stats = '/stats';
  static const String history = '/history';
}

/// Router principal de TimeFlow : `ShellRoute` à 3 onglets (Aujourd'hui /
/// Statistiques / Historique).
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.today,
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => MainShell(
        location: state.uri.toString(),
        child: child,
      ),
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.today,
          pageBuilder: (context, state) =>
              _fadeTransitionPage(state, const TodayScreen()),
        ),
        GoRoute(
          path: AppRoutes.stats,
          pageBuilder: (context, state) =>
              _fadeTransitionPage(state, const StatsScreen()),
        ),
        GoRoute(
          path: AppRoutes.history,
          pageBuilder: (context, state) =>
              _fadeTransitionPage(state, const HistoryScreen()),
        ),
      ],
    ),
  ],
);

/// Page de destination avec un simple fondu (`FadeTransition`) entre les
/// 3 onglets principaux — pas de `StatefulShellRoute` (la perte d'état par
/// onglet, filtre Historique/segment Stats, reste un comportement
/// pré-existant, hors périmètre Phase 5 « Polish & Animations »).
CustomTransitionPage<void> _fadeTransitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: MotionTokens.entrance,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Coquille commune aux 3 onglets : contenu + barre de navigation basse.
class MainShell extends StatelessWidget {
  const MainShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const List<String> _tabs = <String>[
    AppRoutes.today,
    AppRoutes.stats,
    AppRoutes.history,
  ];

  int get _currentIndex {
    final index = _tabs.indexWhere(location.startsWith);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => context.go(_tabs[index]),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            activeIcon: Icon(Icons.today),
            label: "Aujourd'hui",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            activeIcon: Icon(Icons.insert_chart),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}
