import 'package:flutter/material.dart';

/// Jetons de couleur du design system TimeFlow, au-delà de ce que couvre
/// `ColorScheme`. Résolus via `Theme.of(context).extension<TimeFlowColors>()`.
///
/// Les couleurs de catégorie (spécifiques à `CategoryId`) vivent séparément
/// dans `category_colors.dart` — ce fichier ne couvre que les jetons
/// généraux de surface/texte/accent.
@immutable
class TimeFlowColors extends ThemeExtension<TimeFlowColors> {
  const TimeFlowColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.muted,
    required this.border,
    required this.inputBorder,
    required this.accent,
    required this.tabbar,
    required this.shadow,
  });

  /// Fond général de l'écran.
  final Color bg;

  /// Fond des cartes/surfaces principales.
  final Color surface;

  /// Fond des surfaces secondaires (imbriquées dans [surface]).
  final Color surface2;

  /// Couleur de texte principale.
  final Color text;

  /// Couleur de texte secondaire/atténuée.
  final Color muted;

  /// Bordure par défaut (cartes, séparateurs).
  final Color border;

  /// Bordure des champs de saisie.
  final Color inputBorder;

  /// Couleur d'accent (CTA, FAB, éléments actifs).
  final Color accent;

  /// Fond de la barre d'onglets.
  final Color tabbar;

  /// Couleur d'ombre portée.
  final Color shadow;

  static const TimeFlowColors light = TimeFlowColors(
    bg: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF3EEE6),
    text: Color(0xFF211D19),
    muted: Color(0xFF7A7167),
    border: Color(0xFFE7E0D5),
    inputBorder: Color(0xFFD8CFC0),
    accent: Color(0xFFB5632B),
    tabbar: Color(0xFFFFFFFF),
    shadow: Color(0x1A211D19),
  );

  static const TimeFlowColors dark = TimeFlowColors(
    bg: Color(0xFF161311),
    surface: Color(0xFF201B17),
    surface2: Color(0xFF2A241E),
    text: Color(0xFFF3EEE6),
    muted: Color(0xFFA69C8E),
    border: Color(0xFF39322A),
    inputBorder: Color(0xFF4A4136),
    accent: Color(0xFFE0925A),
    tabbar: Color(0xFF201B17),
    shadow: Color(0x33000000),
  );

  @override
  TimeFlowColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? text,
    Color? muted,
    Color? border,
    Color? inputBorder,
    Color? accent,
    Color? tabbar,
    Color? shadow,
  }) {
    return TimeFlowColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      inputBorder: inputBorder ?? this.inputBorder,
      accent: accent ?? this.accent,
      tabbar: tabbar ?? this.tabbar,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  TimeFlowColors lerp(ThemeExtension<TimeFlowColors>? other, double t) {
    if (other is! TimeFlowColors) return this;
    return TimeFlowColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      tabbar: Color.lerp(tabbar, other.tabbar, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
