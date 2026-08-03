import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/theme/design_tokens.dart';
import 'package:timeflow_mobile/widgets/category_chip.dart';

BoxDecoration _decorationOf(WidgetTester tester) {
  final container =
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
  return container.decoration! as BoxDecoration;
}

Color _textColorOf(WidgetTester tester) {
  final text = tester.widgetList<Text>(find.byType(Text)).last;
  return text.style!.color!;
}

void main() {
  group('CategoryChipStyle.badge (comportement historique, non-régression)',
      () {
    testWidgets(
        'sélectionné : fond teinté par color, bordure color 2px, texte color',
        (tester) async {
      const color = Color(0xFF185FA5);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: CategoryChip(
                emoji: '💼', label: 'Travail', color: color, selected: true),
          ),
        ),
      );

      final decoration = _decorationOf(tester);
      expect(decoration.color, color.withValues(alpha: 0.15));
      expect(decoration.border, Border.all(color: color, width: 2));
      expect(_textColorOf(tester), color);
    });

    testWidgets(
        'non sélectionné : fond surface2, bordure tokens.border, texte tokens.text',
        (tester) async {
      const color = Color(0xFF185FA5);
      const tokens = TimeFlowColors.light;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: CategoryChip(
                emoji: '💼', label: 'Travail', color: color, selected: false),
          ),
        ),
      );

      final decoration = _decorationOf(tester);
      expect(decoration.color, tokens.surface2);
      expect(decoration.border, Border.all(color: tokens.border, width: 1));
      expect(_textColorOf(tester), tokens.text);
    });
  });

  group('CategoryChipStyle.pill (filtres Historique, color ignoré)', () {
    testWidgets('sélectionné : fond accent plein, texte blanc, pas de bordure',
        (tester) async {
      const tokens = TimeFlowColors.light;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: CategoryChip(
              emoji: '✦',
              label: 'Tout',
              color: Color(0xFF534AB7),
              selected: true,
              style: CategoryChipStyle.pill,
            ),
          ),
        ),
      );

      final decoration = _decorationOf(tester);
      expect(decoration.color, tokens.accent);
      expect(decoration.border, isNull);
      expect(_textColorOf(tester), Colors.white);
    });

    testWidgets(
        'non sélectionné : fond surface, bordure border, texte tokens.text',
        (tester) async {
      const tokens = TimeFlowColors.light;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: CategoryChip(
              emoji: '✦',
              label: 'Tout',
              color: Color(0xFF534AB7),
              selected: false,
              style: CategoryChipStyle.pill,
            ),
          ),
        ),
      );

      final decoration = _decorationOf(tester);
      expect(decoration.color, tokens.surface);
      expect(decoration.border, Border.all(color: tokens.border, width: 1));
      expect(_textColorOf(tester), tokens.text);
    });
  });
}
