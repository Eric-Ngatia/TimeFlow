import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow_mobile/theme/app_theme.dart';
import 'package:timeflow_mobile/theme/design_tokens.dart';

void main() {
  test('AppTheme.light() se construit sans exception et expose TimeFlowColors', () {
    final theme = AppTheme.light();
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<TimeFlowColors>(), isNotNull);
  });

  test('AppTheme.dark() se construit sans exception et expose TimeFlowColors', () {
    final theme = AppTheme.dark();
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<TimeFlowColors>(), isNotNull);
  });
}
