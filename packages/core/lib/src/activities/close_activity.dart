import 'package:timeflow_domain/timeflow_domain.dart';

import 'duration.dart';
import 'validate_activity.dart';

/// Clôture une activité en cours (RG-03) : renseigne [endTime] et calcule
/// [Activity.durationMin] (RG-04).
///
/// Applique la même règle RG-02 que la création : [endTime] doit être
/// strictement après `current.startTime`, et la durée résultante doit être
/// d'au moins 1 minute. Lève [ActivityValidationException] sinon.
Activity closeActivity(Activity current, DateTime endTime) {
  final result = validateActivity(
    title: current.title,
    category: current.category,
    startTime: current.startTime,
    endTime: endTime,
  );
  if (!result.isValid) {
    throw ActivityValidationException(result);
  }

  return current.copyWith(
    endTime: endTime,
    durationMin: computeDurationMin(current.startTime, endTime),
  );
}
