import 'package:test/test.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

void main() {
  group('categoryMetadata', () {
    test('contient exactement une entrée par CategoryId', () {
      expect(categoryMetadata.keys.toSet(), CategoryId.values.toSet());
      expect(categoryMetadata, hasLength(6));
    });

    test('chaque catégorie a un libellé et un emoji non vides', () {
      for (final id in CategoryId.values) {
        final meta = categoryMetaFor(id);
        expect(meta.id, id);
        expect(meta.label, isNotEmpty);
        expect(meta.emoji, isNotEmpty);
      }
    });
  });
}
