/// Total maximal de minutes suivies par jour (24h) — RG-04.
const int maxMinutesPerDay = 1440;

/// Calcule la durée en minutes entre [start] et [end], arrondie à la minute
/// la plus proche (RG-04).
///
/// Ne valide pas l'ordre de [start]/[end] — voir `validateActivity` pour la
/// règle RG-02 (fin > début).
int computeDurationMin(DateTime start, DateTime end) {
  final diff = end.difference(start);
  return (diff.inSeconds / 60).round();
}

/// Levée quand l'ajout d'une nouvelle activité ferait dépasser le total
/// journalier maximal de [maxMinutesPerDay] minutes (RG-04).
class DailyTotalExceededException implements Exception {
  const DailyTotalExceededException({
    required this.existingMinutes,
    required this.newDurationMin,
  });

  /// Minutes déjà enregistrées ce jour-là, avant l'ajout.
  final int existingMinutes;

  /// Durée de la nouvelle activité, en minutes.
  final int newDurationMin;

  @override
  String toString() =>
      'Le total journalier dépasserait $maxMinutesPerDay minutes '
      '($existingMinutes + $newDurationMin).';
}

/// Vérifie que l'ajout d'une activité de [newDurationMin] minutes à un jour
/// ayant déjà [existingMinutes] minutes enregistrées ne dépasse pas
/// [maxMinutesPerDay] (RG-04). Lève [DailyTotalExceededException] sinon.
void validateDailyTotal(int existingMinutes, int newDurationMin) {
  if (existingMinutes + newDurationMin > maxMinutesPerDay) {
    throw DailyTotalExceededException(
      existingMinutes: existingMinutes,
      newDurationMin: newDurationMin,
    );
  }
}
