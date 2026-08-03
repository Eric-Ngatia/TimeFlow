import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  final start = DateTime(2026, 8, 1, 9);

  group('validateActivity — RG-01 (titre + catégorie obligatoires)', () {
    test('valide quand titre et catégorie sont renseignés', () {
      final result = validateActivity(
        title: 'Réunion',
        category: CategoryId.work,
        startTime: start,
      );
      expect(result.isValid, isTrue);
    });

    test('invalide si le titre est vide', () {
      final result = validateActivity(
        title: '',
        category: CategoryId.work,
        startTime: start,
      );
      expect(result.isValid, isFalse);
      expect(result.errorFor(ValidationField.title), isNotNull);
    });

    test('invalide si le titre ne contient que des espaces', () {
      final result = validateActivity(
        title: '   ',
        category: CategoryId.work,
        startTime: start,
      );
      expect(result.isValid, isFalse);
      expect(result.errorFor(ValidationField.title), isNotNull);
    });

    test('invalide si la catégorie est absente', () {
      final result = validateActivity(
        title: 'Réunion',
        category: null,
        startTime: start,
      );
      expect(result.isValid, isFalse);
      expect(result.errorFor(ValidationField.category), isNotNull);
    });
  });

  group('validateActivity — RG-02 (fin > début, durée min 1 min)', () {
    test('valide sans endTime (activité en cours — RG-03)', () {
      final result = validateActivity(
        title: 'Réunion',
        category: CategoryId.work,
        startTime: start,
      );
      expect(result.isValid, isTrue);
    });

    test('valide quand endTime est après startTime', () {
      final result = validateActivity(
        title: 'Réunion',
        category: CategoryId.work,
        startTime: start,
        endTime: start.add(const Duration(minutes: 30)),
      );
      expect(result.isValid, isTrue);
    });

    test('invalide quand endTime == startTime', () {
      final result = validateActivity(
        title: 'Réunion',
        category: CategoryId.work,
        startTime: start,
        endTime: start,
      );
      expect(result.isValid, isFalse);
      expect(result.errorFor(ValidationField.timeRange), isNotNull);
    });

    test('invalide quand endTime est avant startTime', () {
      final result = validateActivity(
        title: 'Réunion',
        category: CategoryId.work,
        startTime: start,
        endTime: start.subtract(const Duration(minutes: 5)),
      );
      expect(result.isValid, isFalse);
      expect(result.errorFor(ValidationField.timeRange), isNotNull);
    });

    test('invalide quand la durée résultante est < 1 minute', () {
      final result = validateActivity(
        title: 'Réunion',
        category: CategoryId.work,
        startTime: start,
        endTime: start.add(const Duration(seconds: 20)),
      );
      expect(result.isValid, isFalse);
      expect(result.errorFor(ValidationField.timeRange), isNotNull);
    });
  });
}
