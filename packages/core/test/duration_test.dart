import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';

void main() {
  group('computeDurationMin', () {
    test('calcule une durée exacte en minutes', () {
      final start = DateTime(2026, 8, 1, 9, 0);
      final end = DateTime(2026, 8, 1, 10, 30);
      expect(computeDurationMin(start, end), 90);
    });

    test('arrondit à la minute la plus proche (au-dessus)', () {
      final start = DateTime(2026, 8, 1, 9, 0, 0);
      final end = DateTime(2026, 8, 1, 9, 0, 31); // 31s → arrondi à 1 min
      expect(computeDurationMin(start, end), 1);
    });

    test('arrondit à la minute la plus proche (en dessous)', () {
      final start = DateTime(2026, 8, 1, 9, 0, 0);
      final end = DateTime(2026, 8, 1, 9, 0, 29); // 29s → arrondi à 0 min
      expect(computeDurationMin(start, end), 0);
    });
  });

  group('validateDailyTotal', () {
    test("n'échoue pas quand le total reste sous le plafond", () {
      expect(() => validateDailyTotal(1000, 200), returnsNormally);
    });

    test('accepte exactement 1440 minutes cumulées', () {
      expect(() => validateDailyTotal(1400, 40), returnsNormally);
    });

    test('lève une exception au-delà du plafond de 1440 min/jour (RG-04)', () {
      expect(
        () => validateDailyTotal(1400, 41),
        throwsA(isA<DailyTotalExceededException>()),
      );
    });
  });
}
