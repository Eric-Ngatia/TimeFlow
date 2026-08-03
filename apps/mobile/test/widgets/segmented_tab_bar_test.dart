import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/theme/design_tokens.dart';
import 'package:timeflow_mobile/widgets/segmented_tab_bar.dart';

enum _Segment { day, week, month }

void main() {
  Widget buildBar(
      {required _Segment selected, required ValueChanged<_Segment> onChanged}) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SegmentedTabBar<_Segment>(
          segments: const [
            SegmentedTabBarItem(value: _Segment.day, label: 'Jour'),
            SegmentedTabBarItem(value: _Segment.week, label: 'Semaine'),
            SegmentedTabBarItem(value: _Segment.month, label: 'Mois'),
          ],
          selected: selected,
          onChanged: onChanged,
        ),
      ),
    );
  }

  testWidgets('tap sur un segment déclenche onChanged avec la bonne valeur',
      (tester) async {
    _Segment? changedTo;
    await tester.pumpWidget(
      buildBar(selected: _Segment.day, onChanged: (value) => changedTo = value),
    );

    await tester.tap(find.text('Semaine'));
    await tester.pump();

    expect(changedTo, _Segment.week);
  });

  testWidgets(
      'le segment sélectionné a le style actif (fond surface + ombre), les inactifs muted',
      (
    tester,
  ) async {
    const tokens = TimeFlowColors.light;
    await tester
        .pumpWidget(buildBar(selected: _Segment.week, onChanged: (_) {}));

    final containers = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .toList();
    expect(containers, hasLength(3));

    final activeDecoration = containers[1].decoration! as BoxDecoration;
    expect(activeDecoration.color, tokens.surface);
    expect(activeDecoration.boxShadow, isNotNull);
    expect(activeDecoration.boxShadow!.single.color, tokens.shadow);

    final inactiveDayDecoration = containers[0].decoration! as BoxDecoration;
    expect(inactiveDayDecoration.color, Colors.transparent);
    expect(inactiveDayDecoration.boxShadow, isNull);

    final texts = tester.widgetList<Text>(find.byType(Text)).toList();
    final activeText = texts.firstWhere((t) => t.data == 'Semaine');
    final inactiveText = texts.firstWhere((t) => t.data == 'Jour');
    expect(activeText.style!.color, tokens.text);
    expect(inactiveText.style!.color, tokens.muted);
  });
}
