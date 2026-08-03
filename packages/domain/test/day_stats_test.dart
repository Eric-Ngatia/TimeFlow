import 'package:test/test.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('DayStats', () {
    test('construction simple expose les champs fournis', () {
      final stats = DayStats(
        date: '2026-08-01',
        totalMin: 120,
        byCategory: {CategoryId.work: 90, CategoryId.sport: 30},
        productivityScore: 75,
        activitiesCount: 2,
      );

      expect(stats.date, '2026-08-01');
      expect(stats.totalMin, 120);
      expect(stats.byCategory[CategoryId.work], 90);
      expect(stats.productivityScore, 75);
      expect(stats.activitiesCount, 2);
    });

    test('byCategory est protégée en écriture', () {
      final stats = DayStats(
        date: '2026-08-01',
        totalMin: 10,
        byCategory: {CategoryId.work: 10},
        productivityScore: 100,
        activitiesCount: 1,
      );
      expect(() => stats.byCategory[CategoryId.sport] = 5, throwsUnsupportedError);
    });

    test('égalité structurelle', () {
      final a = DayStats(
        date: '2026-08-01',
        totalMin: 10,
        byCategory: {CategoryId.work: 10},
        productivityScore: 100,
        activitiesCount: 1,
      );
      final b = DayStats(
        date: '2026-08-01',
        totalMin: 10,
        byCategory: {CategoryId.work: 10},
        productivityScore: 100,
        activitiesCount: 1,
      );
      expect(a, equals(b));
    });
  });

  group('RangeStats', () {
    test('construction simple agrège plusieurs DayStats', () {
      final day1 = DayStats(
        date: '2026-07-31',
        totalMin: 60,
        byCategory: {CategoryId.work: 60},
        productivityScore: 100,
        activitiesCount: 1,
      );
      final day2 = DayStats(
        date: '2026-08-01',
        totalMin: 40,
        byCategory: {CategoryId.sport: 40},
        productivityScore: 0,
        activitiesCount: 1,
      );

      final range = RangeStats(
        days: [day1, day2],
        averageScore: 50,
        totalMin: 100,
        daysTracked: 2,
      );

      expect(range.days, [day1, day2]);
      expect(range.averageScore, 50);
      expect(range.totalMin, 100);
      expect(range.daysTracked, 2);
    });
  });
}
