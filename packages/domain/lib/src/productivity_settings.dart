/// Seuil de productivité (RG-06 étendu) : borné entre 40 et 80, valeur par
/// défaut 60. Persistable via `SettingsRepository`.
///
/// Il n'existe pas d'écran de réglage dans ce lot (voir plan MVP), mais le
/// type et le stockage sont prêts pour un futur écran Settings.
class ProductivityThreshold {
  /// Construit un seuil, en le bornant automatiquement à [min]..[max].
  factory ProductivityThreshold(int value) {
    final clamped = value.clamp(min, max);
    return ProductivityThreshold._(clamped);
  }

  const ProductivityThreshold._(this.value);

  /// Borne basse acceptée.
  static const int min = 40;

  /// Borne haute acceptée.
  static const int max = 80;

  /// Valeur par défaut si l'utilisateur n'a jamais réglé le seuil.
  static const int defaultValue = 60;

  /// Seuil par défaut, prêt à l'emploi.
  static const ProductivityThreshold standard =
      ProductivityThreshold._(defaultValue);

  /// Valeur bornée entre [min] et [max].
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProductivityThreshold && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ProductivityThreshold($value)';
}

/// Palier de productivité d'une journée, dérivé du score (RG-06) comparé au
/// [ProductivityThreshold] courant.
enum ProductivityLevel {
  /// Score >= seuil.
  productive,

  /// Score >= seuil - 20 mais < seuil.
  correct,

  /// Score < seuil - 20.
  low,
}
