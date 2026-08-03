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
  CategoryId.work: Color(0xFF3F6C8F),
  CategoryId.sport: Color(0xFF4C8C5A),
  CategoryId.leisure: Color(0xFFB5632B),
  CategoryId.sleep: Color(0xFF6E5FA3),
  CategoryId.social: Color(0xFFC24E6E),
  CategoryId.other: Color(0xFF7A7167),
};

const Map<CategoryId, Color> _darkCategoryColors = <CategoryId, Color>{
  CategoryId.work: Color(0xFF7FA9CC),
  CategoryId.sport: Color(0xFF84C08F),
  CategoryId.leisure: Color(0xFFE0925A),
  CategoryId.sleep: Color(0xFFA79BD6),
  CategoryId.social: Color(0xFFE18AA2),
  CategoryId.other: Color(0xFFA69C8E),
};

/// Rendu visuel de toutes les catégories pour la [brightness] donnée.
Map<CategoryId, CategoryVisual> categoryVisuals(Brightness brightness) {
  final colors = brightness == Brightness.dark ? _darkCategoryColors : _lightCategoryColors;
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
  final colors = brightness == Brightness.dark ? _darkCategoryColors : _lightCategoryColors;
  return CategoryVisual(
    id: id,
    emoji: categoryMetaFor(id).emoji,
    label: categoryMetaFor(id).label,
    color: colors[id]!,
  );
}
