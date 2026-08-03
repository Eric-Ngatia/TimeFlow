import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_core/timeflow_core.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../data/activities_dao.dart';
import '../data/database.dart';

/// Base drift — instance unique pour toute l'application (RG-05).
///
/// `keepAlive: true` : la base ne doit jamais être recréée à chaque écran.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}, name: 'databaseProvider');

/// Implémentation drift de [ActivityRepository], injectée dans le reste de
/// l'application — jamais consommée directement comme `ActivitiesDao`.
final Provider<ActivityRepository> activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivitiesDao(ref.watch(databaseProvider)),
  name: 'activityRepositoryProvider',
);

/// Date du jour (`YYYY-MM-DD`, heure locale — RG-05).
String todayDateKey() => formatLocalDate(DateTime.now());

/// Flux des activités du jour courant (écran Aujourd'hui).
final StreamProvider<List<Activity>> todayActivitiesProvider = StreamProvider<List<Activity>>(
  (ref) => ref.watch(activityRepositoryProvider).watchByDate(todayDateKey()),
  name: 'todayActivitiesProvider',
);

/// Activité en cours (RG-03) parmi les activités du jour, `null` si aucune.
final Provider<Activity?> currentActivityProvider = Provider<Activity?>((ref) {
  final activities = ref.watch(todayActivitiesProvider).valueOrNull ?? const <Activity>[];
  for (final activity in activities) {
    if (activity.isInProgress) return activity;
  }
  return null;
}, name: 'currentActivityProvider');
