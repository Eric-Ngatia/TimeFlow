import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Démonte explicitement l'arbre de widgets courant et laisse le temps aux
/// providers Riverpod adossés à des flux drift (`watch()`) de terminer leur
/// nettoyage (drift planifie un `Timer.zero` lors de l'annulation d'un
/// flux — sans cet appel, `flutter_test` détecte un timer résiduel après
/// la fin du test et le fait échouer).
///
/// À appeler en toute fin de test pour tout widget testé sous
/// `ProviderScope` qui `ref.watch` un provider basé sur un flux drift
/// (`todayActivitiesProvider`, `dayStatsProvider`, `weekStatsProvider`,
/// `monthStatsProvider`, `historyProvider`).
Future<void> disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Durée non nulle : nécessaire pour que le timer `Duration.zero` planifié
  // par drift lors de l'annulation du flux soit réellement déclenché sous
  // la zone d'exécution "fake async" de flutter_test (un `pump()` sans
  // durée n'avance pas suffisamment l'horloge simulée).
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}
