import 'package:test/test.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('ProductivityThreshold', () {
    test('valeur par défaut = 60', () {
      expect(ProductivityThreshold.standard.value, 60);
      expect(ProductivityThreshold.defaultValue, 60);
    });

    test('borne les valeurs trop basses à 40', () {
      expect(ProductivityThreshold(0).value, 40);
      expect(ProductivityThreshold(39).value, 40);
    });

    test('borne les valeurs trop hautes à 80', () {
      expect(ProductivityThreshold(999).value, 80);
      expect(ProductivityThreshold(81).value, 80);
    });

    test('laisse passer une valeur déjà dans les bornes', () {
      expect(ProductivityThreshold(40).value, 40);
      expect(ProductivityThreshold(60).value, 60);
      expect(ProductivityThreshold(80).value, 80);
    });

    test('égalité par valeur', () {
      expect(ProductivityThreshold(65), equals(ProductivityThreshold(65)));
    });
  });

  group('ProductivityLevel', () {
    test('expose exactement 3 paliers', () {
      expect(ProductivityLevel.values, hasLength(3));
      expect(
        ProductivityLevel.values,
        containsAll(<ProductivityLevel>[
          ProductivityLevel.productive,
          ProductivityLevel.correct,
          ProductivityLevel.low,
        ]),
      );
    });
  });
}
