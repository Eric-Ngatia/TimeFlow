import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'design_tokens.dart';

/// Thème TimeFlow — clair et sombre, tous deux exposant [TimeFlowColors]
/// via `Theme.of(context).extension<TimeFlowColors>()`.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(TimeFlowColors.light, Brightness.light);

  static ThemeData dark() => _build(TimeFlowColors.dark, Brightness.dark);

  static ThemeData _build(TimeFlowColors tokens, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.accent,
      onPrimary: tokens.surface,
      secondary: tokens.accent,
      onSecondary: tokens.surface,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: tokens.surface,
      onSurface: tokens.text,
    );

    final textTheme =
        buildTextTheme(color: tokens.text, mutedColor: tokens.muted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bg,
      textTheme: textTheme,
      dividerColor: tokens.border,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bg,
        foregroundColor: tokens.text,
        elevation: 0,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.accent, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.accent,
        foregroundColor: tokens.surface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.tabbar,
        selectedItemColor: tokens.tabBarAccent,
        unselectedItemColor: tokens.muted,
      ),
      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }
}
