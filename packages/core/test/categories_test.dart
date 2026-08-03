import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('categoryMetadata', () {
    test('contient exactement une entrée par CategoryId', () {
      expect(categoryMetadata.keys.toSet(), CategoryId.values.toSet());
      expect(categoryMetadata, hasLength(8));
    });

    test('chaque catégorie a un libellé et un emoji non vides', () {
      for (final id in CategoryId.values) {
        final meta = categoryMetaFor(id);
        expect(meta.id, id);
        expect(meta.label, isNotEmpty);
        expect(meta.emoji, isNotEmpty);
      }
    });

    group('isProductive (RG-06)', () {
      test('work, study et side_project sont productives', () {
        expect(categoryMetaFor(CategoryId.work).isProductive, isTrue);
        expect(categoryMetaFor(CategoryId.study).isProductive, isTrue);
        expect(categoryMetaFor(CategoryId.side_project).isProductive, isTrue);
      });

      test('sport, leisure, sleep, social et other ne sont pas productives', () {
        expect(categoryMetaFor(CategoryId.sport).isProductive, isFalse);
        expect(categoryMetaFor(CategoryId.leisure).isProductive, isFalse);
        expect(categoryMetaFor(CategoryId.sleep).isProductive, isFalse);
        expect(categoryMetaFor(CategoryId.social).isProductive, isFalse);
        expect(categoryMetaFor(CategoryId.other).isProductive, isFalse);
      });
    });
  });
}
