import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('createActivity', () {
    test('crée une activité en cours quand endTime est absent (RG-03)', () {
      final start = DateTime(2026, 8, 1, 9, 15);
      final activity = createActivity(
        id: 'a1',
        title: 'Sprint planning',
        category: CategoryId.work,
        startTime: start,
      );

      expect(activity.id, 'a1');
      expect(activity.title, 'Sprint planning');
      expect(activity.category, CategoryId.work);
      expect(activity.startTime, start);
      expect(activity.endTime, isNull);
      expect(activity.durationMin, isNull);
      expect(activity.isInProgress, isTrue);
    });

    test('dérive la date (YYYY-MM-DD) de startTime en heure locale (RG-05)', () {
      final start = DateTime(2026, 3, 5, 23, 50);
      final activity = createActivity(
        id: 'a1',
        title: 'Lecture',
        category: CategoryId.leisure,
        startTime: start,
      );
      expect(activity.date, '2026-03-05');
    });

    test('calcule durationMin quand endTime est fourni (RG-04)', () {
      final start = DateTime(2026, 8, 1, 9);
      final end = DateTime(2026, 8, 1, 10, 15);
      final activity = createActivity(
        id: 'a1',
        title: 'Développement',
        category: CategoryId.work,
        startTime: start,
        endTime: end,
      );
      expect(activity.durationMin, 75);
      expect(activity.isInProgress, isFalse);
    });

    test('rejette un titre vide (RG-01)', () {
      expect(
        () => createActivity(
          id: 'a1',
          title: '',
          category: CategoryId.work,
          startTime: DateTime(2026, 8, 1, 9),
        ),
        throwsA(isA<ActivityValidationException>()),
      );
    });

    test('rejette une heure de fin antérieure au début (RG-02)', () {
      final start = DateTime(2026, 8, 1, 9);
      expect(
        () => createActivity(
          id: 'a1',
          title: 'Réunion',
          category: CategoryId.work,
          startTime: start,
          endTime: start.subtract(const Duration(minutes: 1)),
        ),
        throwsA(isA<ActivityValidationException>()),
      );
    });

    test('utilise startTime comme createdAt par défaut', () {
      final start = DateTime(2026, 8, 1, 9);
      final activity = createActivity(
        id: 'a1',
        title: 'Réunion',
        category: CategoryId.work,
        startTime: start,
      );
      expect(activity.createdAt, start);
    });
  });

  group('formatLocalDate', () {
    test('pad les mois/jours à 2 chiffres', () {
      expect(formatLocalDate(DateTime(2026, 1, 2)), '2026-01-02');
    });
  });
}
