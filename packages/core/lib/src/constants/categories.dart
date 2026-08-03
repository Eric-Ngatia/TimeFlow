import 'package:timeflow_domain/timeflow_domain.dart';

/// Métadonnées d'affichage d'une catégorie : identifiant, libellé FR et
/// emoji. **Pas de couleur ici** — `Color` appartient à Flutter et ne doit
/// jamais apparaître dans `packages/core` (voir CLAUDE.md racine, règle
/// d'architecture #1). Les couleurs vivent dans
/// `apps/mobile/lib/theme/category_colors.dart`.
class CategoryMeta {
  const CategoryMeta({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final CategoryId id;
  final String label;
  final String emoji;
}

/// Métadonnées des 6 catégories du MVP, indexées par [CategoryId].
const Map<CategoryId, CategoryMeta> categoryMetadata = <CategoryId, CategoryMeta>{
  CategoryId.work: CategoryMeta(id: CategoryId.work, label: 'Travail', emoji: '💼'),
  CategoryId.sport: CategoryMeta(id: CategoryId.sport, label: 'Sport', emoji: '🏃'),
  CategoryId.leisure: CategoryMeta(id: CategoryId.leisure, label: 'Loisirs', emoji: '🎮'),
  CategoryId.sleep: CategoryMeta(id: CategoryId.sleep, label: 'Sommeil', emoji: '😴'),
  CategoryId.social: CategoryMeta(id: CategoryId.social, label: 'Social', emoji: '💬'),
  CategoryId.other: CategoryMeta(id: CategoryId.other, label: 'Autre', emoji: '📦'),
};

/// Raccourci pour récupérer les métadonnées d'une catégorie donnée.
CategoryMeta categoryMetaFor(CategoryId id) => categoryMetadata[id]!;
