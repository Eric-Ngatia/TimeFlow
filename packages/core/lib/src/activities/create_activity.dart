import 'package:timeflow_domain/timeflow_domain.dart';

import 'duration.dart';
import 'validate_activity.dart';

/// Formate [dateTime] en `YYYY-MM-DD`, en heure **locale** (RG-05 — pas de
/// conversion UTC). Règle métier centralisée ici pour éviter toute
/// duplication dans `apps/mobile` (ex. calcul de la clé "aujourd'hui").
String formatLocalDate(DateTime dateTime) {
  final y = dateTime.year.toString().padLeft(4, '0');
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Crée une [Activity] validée (RG-01, RG-02) à partir des champs de
/// saisie.
///
/// - [date] est dérivée de [startTime] en heure locale (RG-05).
/// - [durationMin] est calculée si [endTime] est fourni, sinon `null`
///   (activité en cours — RG-03).
/// - Lève [ActivityValidationException] si la saisie est invalide.
///
/// Ne vérifie pas le total journalier (RG-04) : appeler
/// [validateDailyTotal] séparément avec le total déjà enregistré ce
/// jour-là (donnée qui vient du DAO, hors de portée d'une fonction pure).
Activity createActivity({
  required String id,
  required String title,
  required CategoryId category,
  required DateTime startTime,
  DateTime? endTime,
  DateTime? createdAt,
}) {
  final result = validateActivity(
    title: title,
    category: category,
    startTime: startTime,
    endTime: endTime,
  );
  if (!result.isValid) {
    throw ActivityValidationException(result);
  }

  final durationMin = endTime != null ? computeDurationMin(startTime, endTime) : null;

  return Activity(
    id: id,
    title: title.trim(),
    category: category,
    startTime: startTime,
    endTime: endTime,
    durationMin: durationMin,
    date: formatLocalDate(startTime),
    createdAt: createdAt ?? startTime,
  );
}
