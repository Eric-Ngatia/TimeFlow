# TimeFlow — Instructions racine

Monorepo **Flutter + Melos**. Tracker de temps personnel, offline-first, base **SQLite (drift)**.
Lance les commandes depuis la **racine** (routées par Melos) sauf indication contraire.

## Structure

- `apps/mobile`     — Application Flutter (cœur du produit, phases 1→5).
- `apps/api`        — Backend futur (squelette uniquement, ne pas développer sans demande explicite).
- `packages/domain` — Types & contrats partagés (`Activity`, `CategoryId`, `ActivityRepository`). **Dart pur, zéro dépendance Flutter.**
- `packages/core`   — Logique métier pure (règles RG-01..RG-08, stats, durées). **Dart pur, dépend UNIQUEMENT de `domain`.**
- `packages/sync_client` — Client de sync futur (squelette).

## Règles d'architecture (non négociables)

1. **`domain` et `core` ne dépendent jamais** de `flutter`, `drift`, `sqlite3` ou `riverpod`.
   L'accès au stockage passe par l'interface `ActivityRepository` (dans `packages/domain`).
2. Une **règle métier vit une seule fois**, dans `packages/core`. Le mobile ne la duplique jamais.
3. Tout export d'un package passe par son barrel `lib/<package>.dart` (ex. `timeflow_core.dart`).
4. Dates stockées en **ISO 8601 local** (pas de conversion UTC — cf. point d'attention CDC).
5. Ne jamais charger toutes les activités en mémoire pour calculer une stat : écrire une **requête drift** (`WHERE`, `GROUP BY`) qui fait le travail dans SQLite.

## Commandes

- `melos run analyze` / `melos run test` / `melos run format` — sur tout le repo.
- `melos run test --scope=timeflow_core` — cible un package.
- `cd apps/mobile && flutter run` — lance l'app.
- `cd apps/mobile && dart run build_runner build --delete-conflicting-outputs` — codegen drift (`*.g.dart`).

## Workflow OBLIGATOIRE pour toute tâche : Branche → Planification → Exécution → Révision

Aucune tâche de développement ne saute d'étape.

0. **Branche dédiée** — avant toute nouvelle feature, créer une branche git dédiée (`git checkout -b feature/<slug>`, ou via le skill `new-feature` qui scaffolde dossiers + branche). Jamais de nouvelle feature développée directement sur `main`.
1. **Planification** — via `/plan` (agent `planner`). Le plan est **écrit dans `.plans/<slug>.md`** et **validé par un humain** avant tout code.
2. **Exécution** — via `/exec` (agent `executor`). Implémente **strictement** le plan approuvé. Un manque découvert → retour au planner, pas d'improvisation.
3. **Révision** — via `/review` (agent `reviewer`). Vérifie contre le plan + les règles métier, lance `analyze/test`, propose des corrections.

Raccourci : `/task <description>` enchaîne les trois avec un point d'approbation entre Plan et Exec.

## Conventions

- Dart avec lints stricts (`analysis_options.yaml`, `flutter_lints` ou `very_good_analysis`). Pas de `dynamic` implicite non justifié.
- Commits : Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`).
- Tests métier : `dart test` (packages Dart purs), viser 100% sur `packages/core`. Tests DAO avec une base drift **en mémoire** (`NativeDatabase.memory()`).
