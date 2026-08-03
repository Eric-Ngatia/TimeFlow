import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('aggregateRange', () {
    test('combine plusieurs jours triés par date croissante', () {
      final range = aggregateRange(
        minutesByDateAndCategory: {
          '2026-08-03': {CategoryId.work: 60},
          '2026-08-01': {CategoryId.work: 120, CategoryId.sport: 30},
          '2026-08-02': {CategoryId.sleep: 480},
        },
        activitiesCountByDate: {
          '2026-08-01': 2,
          '2026-08-02': 1,
          '2026-08-03': 1,
        },
      );

      expect(range.days.map((d) => d.date).toList(), [
        '2026-08-01',
        '2026-08-02',
        '2026-08-03',
      ]);
      expect(range.totalMin, 120 + 30 + 480 + 60);
      expect(range.daysTracked, 3);
    });

    test('fenêtre de 7 jours glissants avec seulement 3 jours suivis (RG-07)', () {
      // La fenêtre demandée (7 jours) n'est pas modélisée ici : c'est le
      // DAO qui borne la requête SQL. Le nombre de jours *suivis* reflète
      // uniquement les données reçues.
      final range = aggregateRange(
        minutesByDateAndCategory: {
          '2026-07-28': {CategoryId.work: 60},
          '2026-07-30': {CategoryId.work: 60},
          '2026-08-01': {CategoryId.work: 60},
        },
      );
      expect(range.daysTracked, 3);
      expect(range.totalMin, 180);
    });

    test('fenêtre de 30 jours glissants (mois) — moyenne du score', () {
      final range = aggregateRange(
        minutesByDateAndCategory: {
          '2026-07-01': {CategoryId.work: 100}, // score 100
          '2026-07-02': {CategoryId.sport: 100}, // score 0
        },
      );
      expect(range.daysTracked, 2);
      expect(range.averageScore, 50.0);
    });

    test('aucun jour suivi → RangeStats vide, pas de division par zéro', () {
      final range = aggregateRange(minutesByDateAndCategory: const {});
      expect(range.days, isEmpty);
      expect(range.daysTracked, 0);
      expect(range.totalMin, 0);
      expect(range.averageScore, 0.0);
    });

    test('activitiesCountByDate absent pour un jour → défaut 0', () {
      final range = aggregateRange(
        minutesByDateAndCategory: {
          '2026-08-01': {CategoryId.work: 30},
        },
      );
      expect(range.days.single.activitiesCount, 0);
    });
  });

  group('rangeStatsFromDays', () {
    test('combine des DayStats déjà calculés (ex. watchHistory)', () {
      final days = [
        computeDayStats(
          date: '2026-08-01',
          minutesByCategory: {CategoryId.work: 100},
          activitiesCount: 1,
        ),
        computeDayStats(
          date: '2026-08-02',
          minutesByCategory: {CategoryId.sport: 100},
          activitiesCount: 1,
        ),
      ];

      final range = rangeStatsFromDays(days);
      expect(range.daysTracked, 2);
      expect(range.totalMin, 200);
      expect(range.averageScore, 50.0);
    });

    test('liste vide → RangeStats vide, pas de division par zéro', () {
      final range = rangeStatsFromDays(const []);
      expect(range.days, isEmpty);
      expect(range.daysTracked, 0);
      expect(range.totalMin, 0);
      expect(range.averageScore, 0.0);
    });
  });
}
