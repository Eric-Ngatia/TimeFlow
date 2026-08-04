import 'package:flutter/material.dart';

/// Jetons d'animation du design system TimeFlow (durées/courbes), sur le
/// modèle de `design_tokens.dart`. Constantes pures, aucune logique.
///
/// - [fast] : micro-transitions déjà en place (sélection de puce/segment,
///   fondu entre segments Stats, fondu d'apparition/disparition de
///   `CurrentActivityCard`).
/// - [entrance] : animations d'apparition (stagger Timeline/Historique,
///   fondu de navigation par onglets).
/// - [chartEntrance] : animations d'ouverture internes aux graphiques
///   `fl_chart` (barres qui poussent, donut qui balaie), plus longue que
///   [entrance] pour rester perceptible sur jusqu'à 8 catégories.
abstract final class MotionTokens {
  /// Durée des micro-transitions (sélection, fondu de bascule).
  static const Duration fast = Duration(milliseconds: 150);

  /// Durée des animations d'entrée/apparition.
  static const Duration entrance = Duration(milliseconds: 300);

  /// Durée des animations d'ouverture internes aux graphiques Stats
  /// (`WeeklyBarChart`, `CategoryDonutChart`).
  static const Duration chartEntrance = Duration(milliseconds: 600);

  /// Courbe utilisée par les animations d'entrée ([entrance]).
  static const Curve entranceCurve = Curves.easeOutCubic;

  /// Courbe utilisée par les micro-transitions de sélection ([fast]).
  static const Curve selectionCurve = Curves.easeInOut;
}
