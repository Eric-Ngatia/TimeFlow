import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';
import 'package:uuid/uuid.dart';

/// Une entrée de démo : jour relatif à aujourd'hui, heure de début, durée
/// (`null` = activité en cours, RG-03), catégorie, titre.
class _SeedEntry {
  const _SeedEntry({
    required this.daysAgo,
    required this.hour,
    required this.minute,
    required this.durationMin,
    required this.category,
    required this.title,
  });

  final int daysAgo;
  final int hour;
  final int minute;
  final int? durationMin;
  final CategoryId category;
  final String title;
}

const List<_SeedEntry> _entries = <_SeedEntry>[
  // J-4
  _SeedEntry(daysAgo: 4, hour: 7, minute: 0, durationMin: 480, category: CategoryId.sleep, title: 'Nuit de sommeil'),
  _SeedEntry(daysAgo: 4, hour: 9, minute: 0, durationMin: 180, category: CategoryId.work, title: 'Développement TimeFlow'),
  _SeedEntry(daysAgo: 4, hour: 12, minute: 30, durationMin: 45, category: CategoryId.social, title: 'Déjeuner avec Léa'),
  _SeedEntry(daysAgo: 4, hour: 14, minute: 0, durationMin: 180, category: CategoryId.work, title: 'Réunion client'),
  _SeedEntry(daysAgo: 4, hour: 18, minute: 0, durationMin: 60, category: CategoryId.sport, title: 'Course à pied'),
  _SeedEntry(daysAgo: 4, hour: 20, minute: 0, durationMin: 90, category: CategoryId.leisure, title: 'Film du soir'),
  _SeedEntry(daysAgo: 4, hour: 22, minute: 0, durationMin: 60, category: CategoryId.study, title: 'Cours cybersécurité'),

  // J-3
  _SeedEntry(daysAgo: 3, hour: 8, minute: 0, durationMin: 240, category: CategoryId.work, title: 'Sprint planning'),
  _SeedEntry(daysAgo: 3, hour: 12, minute: 0, durationMin: 60, category: CategoryId.other, title: 'Courses'),
  _SeedEntry(daysAgo: 3, hour: 13, minute: 30, durationMin: 210, category: CategoryId.work, title: 'Revue de code'),
  _SeedEntry(daysAgo: 3, hour: 19, minute: 0, durationMin: 45, category: CategoryId.sport, title: 'Yoga'),
  _SeedEntry(daysAgo: 3, hour: 20, minute: 0, durationMin: 90, category: CategoryId.study, title: 'Certification cloud'),

  // J-2
  _SeedEntry(daysAgo: 2, hour: 9, minute: 0, durationMin: 300, category: CategoryId.work, title: 'Développement API'),
  _SeedEntry(daysAgo: 2, hour: 15, minute: 0, durationMin: 60, category: CategoryId.social, title: 'Appel famille'),
  _SeedEntry(daysAgo: 2, hour: 17, minute: 0, durationMin: 90, category: CategoryId.leisure, title: 'Lecture'),
  _SeedEntry(daysAgo: 2, hour: 21, minute: 0, durationMin: 40, category: CategoryId.sport, title: 'Étirements'),
  _SeedEntry(daysAgo: 2, hour: 22, minute: 0, durationMin: 75, category: CategoryId.side_project, title: 'Dev app perso'),

  // J-1
  _SeedEntry(daysAgo: 1, hour: 8, minute: 30, durationMin: 210, category: CategoryId.work, title: 'Design système'),
  _SeedEntry(daysAgo: 1, hour: 12, minute: 15, durationMin: 45, category: CategoryId.other, title: 'Administratif'),
  _SeedEntry(daysAgo: 1, hour: 13, minute: 30, durationMin: 240, category: CategoryId.work, title: 'Intégration drift'),
  _SeedEntry(daysAgo: 1, hour: 18, minute: 30, durationMin: 60, category: CategoryId.sport, title: 'Natation'),
  _SeedEntry(daysAgo: 1, hour: 20, minute: 0, durationMin: 60, category: CategoryId.social, title: 'Dîner entre amis'),
  _SeedEntry(daysAgo: 1, hour: 21, minute: 15, durationMin: 90, category: CategoryId.side_project, title: 'Refonte site web'),

  // Aujourd'hui — la dernière entrée (durationMin: null) reste « en cours »
  // (RG-03) pour visualiser CurrentActivityCard.
  _SeedEntry(daysAgo: 0, hour: 8, minute: 0, durationMin: 180, category: CategoryId.work, title: 'Point équipe'),
  _SeedEntry(daysAgo: 0, hour: 12, minute: 0, durationMin: 45, category: CategoryId.other, title: 'Déjeuner'),
  _SeedEntry(daysAgo: 0, hour: 13, minute: 30, durationMin: null, category: CategoryId.work, title: 'Développement écrans TimeFlow'),
];

/// Insère des activités de démonstration variées (8 catégories, 5 jours)
/// via le [repository] — jamais de SQL brut — pour visualiser la
/// chronologie, les graphiques et l'historique sans saisie manuelle.
///
/// Idempotent en usage normal : appelée une fois sur une base vide (voir
/// point d'entrée de développement), chaque appel supplémentaire ajoute de
/// nouvelles activités (les `id` sont régénérés à chaque appel).
Future<void> seedDemoData(ActivityRepository repository) async {
  const uuid = Uuid();
  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);

  for (final entry in _entries) {
    final day = todayMidnight.subtract(Duration(days: entry.daysAgo));
    final start = DateTime(day.year, day.month, day.day, entry.hour, entry.minute);
    final end = entry.durationMin == null ? null : start.add(Duration(minutes: entry.durationMin!));

    final activity = createActivity(
      id: uuid.v4(),
      title: entry.title,
      category: entry.category,
      startTime: start,
      endTime: end,
    );

    await repository.save(activity);
  }
}
