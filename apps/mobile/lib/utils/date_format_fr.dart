/// Helpers de formatage de date en français, réutilisés par l'écran
/// Historique et la bottom sheet de détail d'un jour.
///
/// Affichage pur — aucune règle métier.
library;

const List<String> _monthLabelsFr = <String>[
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

const List<String> _weekdayLabelsFr = <String>[
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

/// Formatte un jour en `"16 juil."` (jour + mois abrégé en minuscules).
String formatDayLabel(DateTime date) =>
    '${date.day} ${_monthLabelsFr[date.month - 1]}';

/// Formatte le jour de la semaine en majuscules, ex. `"MERCREDI"`.
String formatWeekdayLabel(DateTime date) =>
    _weekdayLabelsFr[date.weekday - 1].toUpperCase();
