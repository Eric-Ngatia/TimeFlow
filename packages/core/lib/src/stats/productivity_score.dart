import 'package:timeflow_domain/timeflow_domain.dart';

/// Calcule le score de productivité (0..100) d'une répartition de minutes
/// par catégorie : `minutes(work) / total * 100`, arrondi (RG-06).
///
/// Renvoie `0` si le total est nul (aucune activité) — jamais de division
/// par zéro.
int productivityScore(Map<CategoryId, int> byCategory) {
  final total = byCategory.values.fold<int>(0, (sum, minutes) => sum + minutes);
  if (total <= 0) return 0;
  final work = byCategory[CategoryId.work] ?? 0;
  return ((work / total) * 100).round();
}

/// Détermine le palier de productivité pour un [score] (0..100) donné,
/// selon un [threshold] réglable (RG-06 étendu, défaut
/// [ProductivityThreshold.defaultValue]) :
/// - `score >= threshold` → [ProductivityLevel.productive]
/// - `score >= threshold - 20` → [ProductivityLevel.correct]
/// - sinon → [ProductivityLevel.low]
ProductivityLevel productivityLevel(
  int score, {
  int threshold = ProductivityThreshold.defaultValue,
}) {
  if (score >= threshold) return ProductivityLevel.productive;
  if (score >= threshold - 20) return ProductivityLevel.correct;
  return ProductivityLevel.low;
}
