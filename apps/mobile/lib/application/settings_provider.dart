import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow_domain/timeflow_domain.dart';

import '../data/settings_dao.dart';
import 'activities_provider.dart';

/// Implémentation drift de [SettingsRepository].
final Provider<SettingsRepository> settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsDao(ref.watch(databaseProvider)),
  name: 'settingsRepositoryProvider',
);

/// Seuil de productivité courant (RG-06 étendu, 40..80, défaut
/// [ProductivityThreshold.defaultValue]).
///
/// Aucun écran de réglage dans ce lot : ce provider n'est consommé qu'en
/// lecture (`productivityLevel(score, threshold: ...)`), prêt pour un futur
/// écran Settings qui appellerait `setProductivityThreshold`.
final StreamProvider<int> productivityThresholdProvider = StreamProvider<int>(
  (ref) => ref.watch(settingsRepositoryProvider).watchProductivityThreshold(),
  name: 'productivityThresholdProvider',
);
