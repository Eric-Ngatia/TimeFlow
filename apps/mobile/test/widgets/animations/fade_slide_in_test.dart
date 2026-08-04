import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/widgets/animations/fade_slide_in.dart';

double _opacityOf(WidgetTester tester) {
  final transition = tester.widget<FadeTransition>(
    find.descendant(
      of: find.byType(FadeSlideIn),
      matching: find.byType(FadeTransition),
    ),
  );
  return transition.opacity.value;
}

void main() {
  testWidgets(
      'avec un delay non nul, opacité proche de 0 juste après le premier pump()',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeSlideIn(
          delay: Duration(milliseconds: 200),
          child: Text('contenu'),
        ),
      ),
    );
    // Un seul pump() sans durée : le Future.delayed(delay, ...) n'a pas
    // encore déclenché forward(), l'animation n'a donc pas démarré.
    await tester.pump();

    expect(_opacityOf(tester), 0.0);

    // Purge le Timer du `Future.delayed` en attente avant la fin du test
    // (sinon `flutter_test` détecte un timer résiduel à la clôture).
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });

  testWidgets('opacité à 1 après pumpAndSettle()', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeSlideIn(
          delay: Duration(milliseconds: 200),
          child: Text('contenu'),
        ),
      ),
    );
    // `pumpAndSettle()` ne fait avancer l'horloge simulée que tant qu'une
    // frame est planifiée : tant que le `Future.delayed` n'a pas déclenché
    // `forward()`, aucune frame n'est planifiée. On avance donc d'abord
    // manuellement le temps du délai avant d'appeler `pumpAndSettle()` pour
    // laisser l'animation se dérouler jusqu'à son terme.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(_opacityOf(tester), 1.0);
    expect(find.text('contenu'), findsOneWidget);
  });

  testWidgets(
      'avec delay: Duration.zero, pumpAndSettle() se termine sans dépassement de timeout',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeSlideIn(child: Text('contenu')),
      ),
    );
    await tester.pumpAndSettle();

    expect(_opacityOf(tester), 1.0);
  });

  testWidgets("dispose() ne lève pas d'exception après démontage prématuré",
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeSlideIn(
          delay: Duration(milliseconds: 200),
          child: Text('contenu'),
        ),
      ),
    );
    await tester.pump();

    // Démonte avant l'expiration du délai : le Future.delayed en attente ne
    // doit pas provoquer d'exception (garde `if (mounted)` dans initState).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
  });
}
