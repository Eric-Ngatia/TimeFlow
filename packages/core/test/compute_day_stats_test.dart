import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('computeDayStats', () {
    test('agrège totalMin, score et activitiesCount depuis une répartition', () {
      final stats = computeDayStats(
        date: '2026-08-01',
        minutesByCategory: {
          CategoryId.work: 180,
          CategoryId.sport: 60,
        },
        activitiesCount: 3,
      );

      expect(stats.date, '2026-08-01');
      expect(stats.totalMin, 240);
      expect(stats.productivityScore, 75); // 180/240 = 75%
      expect(stats.activitiesCount, 3);
      expect(stats.byCategory[CategoryId.work], 180);
      expect(stats.byCategory[CategoryId.sport], 60);
    });

    test('journée vide → totalMin 0, score 0 (pas de division par zéro)', () {
      final stats = computeDayStats(
        date: '2026-08-02',
        minutesByCategory: const {},
        activitiesCount: 0,
      );
      expect(stats.totalMin, 0);
      expect(stats.productivityScore, 0);
      expect(stats.activitiesCount, 0);
    });
  });
}
