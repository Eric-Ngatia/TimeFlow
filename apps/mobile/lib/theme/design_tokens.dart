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
    required this.tabBarAccent,
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

  /// Couleur d'accent spécifique à l'état actif de la barre d'onglets basse,
  /// distincte de [accent].
  final Color tabBarAccent;

  static const TimeFlowColors light = TimeFlowColors(
    bg: Color(0xFFF7F6F2),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFFBFAF6),
    text: Color(0xFF1C1B1A),
    muted: Color(0xFF8A94A0),
    border: Color(0xFFE7E3DA),
    inputBorder: Color(0xFFDAD5CB),
    accent: Color(0xFF1A3A5C),
    tabbar: Color(0xDBF7F6F2),
    shadow: Color(0x0D000000),
    tabBarAccent: Color(0xFF1A3A5C),
  );

  static const TimeFlowColors dark = TimeFlowColors(
    bg: Color(0xFF12161B),
    surface: Color(0xFF1C2229),
    surface2: Color(0xFF161B21),
    text: Color(0xFFECEAE4),
    muted: Color(0xFF6B7280),
    border: Color(0xFF2A313A),
    inputBorder: Color(0xFF39424D),
    accent: Color(0xFF3E7CB8),
    tabbar: Color(0xDB12161B),
    shadow: Color(0x66000000),
    tabBarAccent: Color(0xFF6EA8DA),
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
    Color? tabBarAccent,
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
      tabBarAccent: tabBarAccent ?? this.tabBarAccent,
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
      tabBarAccent: Color.lerp(tabBarAccent, other.tabBarAccent, t)!,
    );
  }
}
