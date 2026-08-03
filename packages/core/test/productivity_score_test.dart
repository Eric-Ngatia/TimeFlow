import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('productivityScore', () {
    test('100% quand tout le temps est en catégorie work', () {
      expect(productivityScore({CategoryId.work: 120}), 100);
    });

    test('0% quand aucune minute en work', () {
      expect(productivityScore({CategoryId.sport: 60, CategoryId.sleep: 60}), 0);
    });

    test('arrondit le pourcentage', () {
      // 1/3 = 33.33... → 33
      expect(productivityScore({CategoryId.work: 1, CategoryId.sport: 2}), 33);
    });

    test('renvoie 0 sans division par zéro quand la map est vide', () {
      expect(productivityScore(<CategoryId, int>{}), 0);
    });

    test('renvoie 0 sans division par zéro quand le total est 0', () {
      expect(productivityScore({CategoryId.work: 0, CategoryId.sport: 0}), 0);
    });
  });

  group('productivityLevel — bornes exactes (seuil par défaut 60)', () {
    test('score == 60 est productive (borne haute incluse)', () {
      expect(productivityLevel(60), ProductivityLevel.productive);
    });

    test('score == 59 est correct', () {
      expect(productivityLevel(59), ProductivityLevel.correct);
    });

    test('score == 40 est correct (borne basse incluse)', () {
      expect(productivityLevel(40), ProductivityLevel.correct);
    });

    test('score == 39 est low', () {
      expect(productivityLevel(39), ProductivityLevel.low);
    });

    test('score == 0 est low', () {
      expect(productivityLevel(0), ProductivityLevel.low);
    });

    test('score == 100 est productive', () {
      expect(productivityLevel(100), ProductivityLevel.productive);
    });
  });

  group('productivityLevel — seuil réglable (RG-06 étendu)', () {
    test('seuil 80 : 80 est productive, 79 correct, 59 low', () {
      expect(productivityLevel(80, threshold: 80), ProductivityLevel.productive);
      expect(productivityLevel(79, threshold: 80), ProductivityLevel.correct);
      expect(productivityLevel(59, threshold: 80), ProductivityLevel.low);
    });

    test('seuil 40 : 40 est productive, 39 correct, 19 low', () {
      expect(productivityLevel(40, threshold: 40), ProductivityLevel.productive);
      expect(productivityLevel(39, threshold: 40), ProductivityLevel.correct);
      expect(productivityLevel(19, threshold: 40), ProductivityLevel.low);
    });
  });
}
