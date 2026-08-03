import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('closeActivity', () {
    final start = DateTime(2026, 8, 1, 9);
    Activity buildInProgress() => Activity(
          id: 'a1',
          title: 'Réunion',
          category: CategoryId.work,
          startTime: start,
          date: '2026-08-01',
          createdAt: start,
        );

    test('renseigne endTime et durationMin (RG-03, RG-04)', () {
      final closed = closeActivity(buildInProgress(), start.add(const Duration(minutes: 45)));
      expect(closed.endTime, start.add(const Duration(minutes: 45)));
      expect(closed.durationMin, 45);
      expect(closed.isInProgress, isFalse);
    });

    test('conserve les autres champs inchangés', () {
      final activity = buildInProgress();
      final closed = closeActivity(activity, start.add(const Duration(minutes: 10)));
      expect(closed.id, activity.id);
      expect(closed.title, activity.title);
      expect(closed.category, activity.category);
      expect(closed.startTime, activity.startTime);
      expect(closed.date, activity.date);
    });

    test('rejette une heure de fin avant le début (RG-02)', () {
      expect(
        () => closeActivity(buildInProgress(), start.subtract(const Duration(minutes: 1))),
        throwsA(isA<ActivityValidationException>()),
      );
    });

    test('rejette une durée résultante < 1 minute (RG-02)', () {
      expect(
        () => closeActivity(buildInProgress(), start.add(const Duration(seconds: 10))),
        throwsA(isA<ActivityValidationException>()),
      );
    });
  });
}
