---
name: flutter-setup
description: Configuration Flutter pour TimeFlow — drift (SQLite), Riverpod, go_router, fl_chart, codegen. Utiliser lors du setup initial (phase 1) ou en cas de souci de build/codegen.
---

# Setup Flutter TimeFlow

## À faire dès la phase 1 (évite les conflits en phase 2)
1. `pubspec.yaml` : ajouter `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `flutter_riverpod`, `go_router`, `fl_chart`, `uuid`, `intl`.
2. `dev_dependencies` : `build_runner`, `drift_dev` — nécessaires pour générer `database.g.dart` à partir de `tables.dart`.
3. Après toute modification du schéma (`lib/data/tables.dart`), régénérer :
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Envelopper `main.dart` avec `ProviderScope` (Riverpod) dès le premier commit.
5. Navigation : `go_router` avec une `ShellRoute` pour les 3 onglets (Aujourd'hui / Stats / Historique) + routes modales pour les bottom sheets.

## Rappels
- Dates en ISO 8601 **local** de bout en bout (pas de `.toUtc()`).
- UUID via le package `uuid` (`Uuid().v4()`) pour chaque activité (champ `id`).
- La base drift s'ouvre une seule fois (singleton via un provider Riverpod), jamais recréée à chaque écran.
