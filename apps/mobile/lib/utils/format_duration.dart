/// Formate un nombre de minutes en libellé compact `XhYY` ou `Ymin`.
///
/// Pur affichage (pas une règle métier) : la valeur en minutes vient
/// toujours d'un calcul `packages/core` (`DayStats.totalMin`,
/// `RangeStats.totalMin`), jamais recalculée ici.
String formatDurationLabel(int totalMin) {
  final hours = totalMin ~/ 60;
  final minutes = totalMin % 60;
  if (hours == 0) return '${minutes}min';
  return '${hours}h${minutes.toString().padLeft(2, '0')}';
}
