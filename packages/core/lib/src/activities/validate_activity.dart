import 'package:timeflow_domain/timeflow_domain.dart';

import 'duration.dart';

/// Champ concerné par une erreur de validation d'activité.
enum ValidationField {
  /// RG-01 — titre obligatoire.
  title,

  /// RG-01 — catégorie obligatoire.
  category,

  /// RG-02 — fin > début, durée minimale 1 minute.
  timeRange,
}

/// Résultat de la validation d'un formulaire d'activité (RG-01, RG-02).
///
/// Pensé pour un affichage inline des erreurs (un message par champ),
/// contrairement à une simple exception qui ne porterait qu'une erreur.
class ValidationResult {
  const ValidationResult({this.errors = const <ValidationField, String>{}});

  /// Un message d'erreur par champ invalide. Vide si [isValid].
  final Map<ValidationField, String> errors;

  bool get isValid => errors.isEmpty;

  /// Message d'erreur pour [field], `null` si ce champ est valide.
  String? errorFor(ValidationField field) => errors[field];
}

/// Levée quand une activité invalide est soumise à une fonction qui exige
/// un résultat valide (ex. `createActivity`, `closeActivity`).
class ActivityValidationException implements Exception {
  const ActivityValidationException(this.result);

  final ValidationResult result;

  @override
  String toString() => result.errors.values.join(' ');
}

/// Valide les champs d'une activité en cours de saisie (RG-01, RG-02).
///
/// - RG-01 : [title] non vide (après trim), [category] renseignée.
/// - RG-02 : si [endTime] est fourni, il doit être strictement après
///   [startTime] et la durée résultante doit être d'au moins 1 minute.
///
/// Ne valide jamais le total journalier (RG-04) — voir [validateDailyTotal],
/// qui nécessite une donnée externe (total déjà enregistré ce jour-là).
ValidationResult validateActivity({
  required String title,
  required CategoryId? category,
  required DateTime startTime,
  DateTime? endTime,
}) {
  final errors = <ValidationField, String>{};

  if (title.trim().isEmpty) {
    errors[ValidationField.title] = 'Le titre est obligatoire.';
  }

  if (category == null) {
    errors[ValidationField.category] = 'La catégorie est obligatoire.';
  }

  if (endTime != null) {
    if (!endTime.isAfter(startTime)) {
      errors[ValidationField.timeRange] =
          "L'heure de fin doit être après l'heure de début.";
    } else if (computeDurationMin(startTime, endTime) < 1) {
      errors[ValidationField.timeRange] = 'La durée minimale est de 1 minute.';
    }
  }

  return errors.isEmpty ? const ValidationResult() : ValidationResult(errors: errors);
}
