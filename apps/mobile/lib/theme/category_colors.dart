import 'package:flutter/material.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

/// Rendu visuel complet d'une catégorie pour l'UI : emoji + libellé
/// (venant de `packages/core`, seule source de vérité pour ces champs) et
/// couleur (propre à Flutter, ne peut donc vivre que dans `apps/mobile`).
@immutable
class CategoryVisual {
  const CategoryVisual({
    required this.id,
    required this.emoji,
    required this.label,
    required this.color,
  });

  final CategoryId id;
  final String emoji;
  final String label;
  final Color color;
}

const Map<CategoryId, Color> _lightCategoryColors = <CategoryId, Color>{
  CategoryId.work: Color(0xFF185FA5),
  CategoryId.sport: Color(0xFF0F6E56),
  CategoryId.leisure: Color(0xFF534AB7),
  CategoryId.sleep: Color(0xFF0E7490),
  CategoryId.social: Color(0xFFD4537E),
  CategoryId.other: Color(0xFF9A6410),
};

const Map<CategoryId, Color> _darkCategoryColors = <CategoryId, Color>{
  CategoryId.work: Color(0xFF5AA0E6),
  CategoryId.sport: Color(0xFF38C39C),
  CategoryId.leisure: Color(0xFF9A90F0),
  CategoryId.sleep: Color(0xFF45C0DC),
  CategoryId.social: Color(0xFFF080A6),
  CategoryId.other: Color(0xFFE0A64A),
};

/// Rendu visuel de toutes les catégories pour la [brightness] donnée.
Map<CategoryId, CategoryVisual> categoryVisuals(Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? _darkCategoryColors
      : _lightCategoryColors;
  return <CategoryId, CategoryVisual>{
    for (final id in CategoryId.values)
      id: CategoryVisual(
        id: id,
        emoji: categoryMetaFor(id).emoji,
        label: categoryMetaFor(id).label,
        color: colors[id]!,
      ),
  };
}

/// Rendu visuel d'une seule catégorie pour la [brightness] donnée.
CategoryVisual categoryVisualFor(CategoryId id, Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? _darkCategoryColors
      : _lightCategoryColors;
  return CategoryVisual(
    id: id,
    emoji: categoryMetaFor(id).emoji,
    label: categoryMetaFor(id).label,
    color: colors[id]!,
  );
}
