import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

/// Base de données locale TimeFlow (SQLite via drift).
///
/// Ouverte **une seule fois** pour toute l'application, via le singleton
/// exposé par `apps/mobile/lib/application/*_provider.dart` (Riverpod) —
/// jamais recréée à chaque écran.
@DriftDatabase(tables: [Activities, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Constructeur pratique pour les tests : base en mémoire.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'timeflow.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
