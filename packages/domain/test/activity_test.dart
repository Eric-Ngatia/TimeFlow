import 'package:test/test.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('CategoryId', () {
    test('expose exactement les 6 catégories du MVP', () {
      expect(CategoryId.values, hasLength(6));
      expect(
        CategoryId.values,
        containsAll(<CategoryId>[
          CategoryId.work,
          CategoryId.sport,
          CategoryId.leisure,
          CategoryId.sleep,
          CategoryId.social,
          CategoryId.other,
        ]),
      );
    });
  });

  group('Activity', () {
    final start = DateTime(2026, 8, 1, 9);
    final created = DateTime(2026, 8, 1, 9);

    Activity buildInProgress() => Activity(
          id: 'a1',
          title: 'Réunion',
          category: CategoryId.work,
          startTime: start,
          date: '2026-08-01',
          createdAt: created,
        );

    test('isInProgress est vrai tant que endTime est null (RG-03)', () {
      final activity = buildInProgress();
      expect(activity.isInProgress, isTrue);
      expect(activity.endTime, isNull);
      expect(activity.durationMin, isNull);
    });

    test('copyWith ne modifie que les champs fournis', () {
      final activity = buildInProgress();
      final renamed = activity.copyWith(title: 'Réunion équipe');

      expect(renamed.title, 'Réunion équipe');
      expect(renamed.id, activity.id);
      expect(renamed.category, activity.category);
      expect(renamed.startTime, activity.startTime);
      expect(renamed.isInProgress, isTrue);
    });

    test('copyWith peut explicitement remettre endTime à null', () {
      final closed = buildInProgress().copyWith(
        endTime: DateTime(2026, 8, 1, 10),
        durationMin: 60,
      );
      expect(closed.isInProgress, isFalse);

      final reopened = closed.copyWith(endTime: null, durationMin: null);
      expect(reopened.isInProgress, isTrue);
      expect(reopened.durationMin, isNull);
    });

    test('deux activités avec les mêmes champs sont égales', () {
      final a = buildInProgress();
      final b = buildInProgress();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
