import 'package:flutter/material.dart';

const String _playfairDisplay = 'Playfair Display';
const String _dmSans = 'DM Sans';
const String _dmMono = 'DM Mono';

/// Construit le [TextTheme] TimeFlow :
/// - **Playfair Display** (serif) pour les titres (`display*`, `headline*`).
/// - **DM Sans** pour le corps de texte et les contrôles (`title*`, `body*`,
///   `labelLarge`).
/// - **DM Mono**, tracking large, pour les petits libellés/chiffres
///   (`labelMedium`, `labelSmall`) — typiquement affichés en MAJUSCULES par
///   l'appelant (ex. `text.toUpperCase()`), la police ne le fait pas
///   automatiquement.
TextTheme buildTextTheme({required Color color, required Color mutedColor}) {
  return TextTheme(
    displayLarge: TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 1.15,
      color: color,
    ),
    displayMedium: TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: color,
    ),
    displaySmall: TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 28,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: color,
    ),
    headlineLarge: TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: color,
    ),
    headlineMedium: TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: color,
    ),
    headlineSmall: TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: color,
    ),
    titleLarge: TextStyle(
      fontFamily: _dmSans,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color,
    ),
    titleMedium: TextStyle(
      fontFamily: _dmSans,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
    ),
    titleSmall: TextStyle(
      fontFamily: _dmSans,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
    ),
    bodyLarge: TextStyle(
      fontFamily: _dmSans,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    ),
    bodyMedium: TextStyle(
      fontFamily: _dmSans,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    ),
    bodySmall: TextStyle(
      fontFamily: _dmSans,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: mutedColor,
    ),
    labelLarge: TextStyle(
      fontFamily: _dmSans,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: color,
    ),
    labelMedium: TextStyle(
      fontFamily: _dmMono,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.2,
      color: mutedColor,
    ),
    labelSmall: TextStyle(
      fontFamily: _dmMono,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.4,
      color: mutedColor,
    ),
  );
}
