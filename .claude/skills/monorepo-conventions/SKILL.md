---
name: monorepo-conventions
description: Conventions du monorepo TimeFlow (Melos, où placer le code, graphe de dépendances). Utiliser pour créer un package, ajouter une dépendance, décider où va un fichier, ou lancer des commandes d'analyse/test.
---

# Conventions monorepo TimeFlow (Flutter + Melos)

## Outillage
- **Melos** (packages déclarés dans `melos.yaml`, sous `apps/**` et `packages/**`).
- Melos orchestre `analyze`, `test`, `format`, `build_runner` (voir scripts dans `melos.yaml`).
- Toujours lancer depuis la racine, ou cibler : `melos exec --scope=<package_name> -- "<commande>"`.

## Où va quoi
| Type de code | Package |
|---------------|---------|
| Type/interface partagé (`Activity`, `ActivityRepository`) | `packages/domain` |
| Règle métier, calcul, validation | `packages/core` |
| Écran, widget, animation | `apps/mobile/lib` |
| Implémentation d'un `ActivityRepository` | `apps/mobile/lib/data` (drift) ou `packages/sync_client` (sync future) |
| Schéma SQL (tables drift) | `apps/mobile/lib/data/tables.dart` |

## Graphe de dépendances (à ne jamais violer)
`domain` → `core` → (`apps/mobile`, `apps/api`, `sync_client`)
- `domain` et `core` sont des packages **Dart purs** (`environment: sdk: dart` dans leur `pubspec.yaml`, pas de dépendance `flutter`). C'est le pubspec lui-même qui empêche mécaniquement toute fuite de Flutter/drift/riverpod dans ces packages.
- Dépendance interne via un chemin relatif (`path: ../domain`) dans les `pubspec.yaml`.
- Chaque package exporte via un unique barrel `lib/<nom_package>.dart`.

## Ajout d'un package
1. `melos create <name>` (ou `mkdir packages/<name>` + `pubspec.yaml` manuel si le package doit rester Dart pur).
2. Déclarer `name: timeflow_<name>` dans le `pubspec.yaml`.
3. L'ajouter au consommateur avec `timeflow_<name>: { path: ../<name> }`.
4. Vérifier `melos bootstrap` puis `melos run analyze --scope=timeflow_<name>`.
