import 'package:timeflow_domain/timeflow_domain.dart';

/// Métadonnées d'affichage d'une catégorie : identifiant, libellé FR,
/// emoji et statut productif (RG-06). **Pas de couleur ici** — `Color`
/// appartient à Flutter et ne doit jamais apparaître dans `packages/core`
/// (voir CLAUDE.md racine, règle d'architecture #1). Les couleurs vivent
/// dans `apps/mobile/lib/theme/category_colors.dart`.
class CategoryMeta {
  const CategoryMeta({
    required this.id,
    required this.label,
    required this.emoji,
    required this.isProductive,
  });

  final CategoryId id;
  final String label;
  final String emoji;

  /// `true` si cette catégorie compte dans le score de productivité (RG-06).
  /// Champ requis (pas de valeur par défaut) : toute nouvelle catégorie doit
  /// se prononcer explicitement, sinon le code ne compile pas.
  final bool isProductive;
}

/// Métadonnées des 8 catégories du MVP, indexées par [CategoryId].
const Map<CategoryId, CategoryMeta> categoryMetadata = <CategoryId, CategoryMeta>{
  CategoryId.work: CategoryMeta(
    id: CategoryId.work,
    label: 'Travail',
    emoji: '💼',
    isProductive: true,
  ),
  CategoryId.study: CategoryMeta(
    id: CategoryId.study,
    label: 'Formation',
    emoji: '📚',
    isProductive: true,
  ),
  CategoryId.side_project: CategoryMeta(
    id: CategoryId.side_project,
    label: 'Projet perso',
    emoji: '🛠️',
    isProductive: true,
  ),
  CategoryId.sport: CategoryMeta(
    id: CategoryId.sport,
    label: 'Sport',
    emoji: '🏃',
    isProductive: false,
  ),
  CategoryId.leisure: CategoryMeta(
    id: CategoryId.leisure,
    label: 'Loisirs',
    emoji: '🎮',
    isProductive: false,
  ),
  CategoryId.sleep: CategoryMeta(
    id: CategoryId.sleep,
    label: 'Sommeil',
    emoji: '😴',
    isProductive: false,
  ),
  CategoryId.social: CategoryMeta(
    id: CategoryId.social,
    label: 'Social',
    emoji: '💬',
    isProductive: false,
  ),
  CategoryId.other: CategoryMeta(
    id: CategoryId.other,
    label: 'Autre',
    emoji: '📦',
    isProductive: false,
  ),
};

/// Raccourci pour récupérer les métadonnées d'une catégorie donnée.
CategoryMeta categoryMetaFor(CategoryId id) => categoryMetadata[id]!;
