# TimeFlow — Architecture Monorepo & Configuration Claude Code (Flutter)

> Proposition d'architecture pour le projet **TimeFlow** (tracker de temps personnel, **Flutter**, offline-first, base **SQLite embarquée**).
> Périmètre retenu : **mobile + backend/sync futur**. Outillage : **Melos** (gestionnaire de monorepo Dart/Flutter, l'équivalent de pnpm+Turborepo côté Dart).
> Configuration Claude Code alignée sur la doc officielle *Set up Claude Code in a monorepo* (CLAUDE.md imbriqués, skills par package, sous-agents, commandes, hooks).
> Séquence imposée pour chaque tâche : **Planification → Exécution → Révision**.

---

## 1. Principes directeurs

| # | Principe | Traduction concrète dans le repo |
|---|----------|-----------------------------------|
| 1 | **Séparer le métier de l'UI** | Toute la logique (règles RG-01→RG-08, calcul stats, durées, score) vit dans `packages/core`, un package **Dart pur** sans dépendance Flutter. Testable en isolation avec `dart test`. |
| 2 | **Le mobile ne réimplémente jamais une règle métier** | `apps/mobile` consomme `timeflow_core` et `timeflow_domain`. L'écran ne fait qu'orchestrer (via Riverpod) + afficher. |
| 3 | **Storage abstrait derrière une interface** | Conseil « tech lead » du CDC : le DAO est une *interface* (`ActivityRepository`) dans `domain`, implémentée par **drift/SQLite** aujourd'hui, par une API de sync demain — zéro refactor côté métier. |
| 4 | **Prêt pour le backend sans le construire maintenant** | `apps/api` et `packages/sync_client` existent en squelette (placeholders, stack Node.js/Fastify — cohérent avec le reste de ton parc de projets) pour matérialiser la frontière, mais ne sont pas développés en phase 1→5. |
| 5 | **Context Claude minimal & ciblé** | Un `CLAUDE.md` racine léger + un `CLAUDE.md` par package. Skills scoping par dossier. Deny-rules sur `build/`, `.dart_tool/`, `*.g.dart` générés. |
| 6 | **Chaque tâche suit Plan → Exec → Review** | Matérialisé par 3 sous-agents dédiés + 3 slash-commands + un template de plan écrit sur disque (survit au compactage de contexte). |

---

## 2. Pourquoi Melos et pas un simple `flutter create` monolithique

Le CDC original React Native isolait déjà la logique métier (`packages/core`) du framework UI. Pour préserver ce même bénéfice en Flutter — testabilité, zéro fuite d'UI dans le métier, préparation d'un futur package de sync — on garde la même séparation, avec l'outil natif de l'écosystème Dart :

- **Melos** gère plusieurs packages Dart/Flutter dans un seul repo Git (équivalent pnpm workspaces + Turborepo).
- Chaque package a son propre `pubspec.yaml` et peut être testé indépendamment (`melos run test`).
- `packages/domain` et `packages/core` sont des packages **Dart purs** (`sdk: dart`, pas `flutter`) — donc mécaniquement interdits de dépendre de Flutter, Riverpod ou drift. Ce n'est pas qu'une convention documentée : c'est imposé par le `pubspec.yaml` lui-même.

---

## 3. Vue d'ensemble de l'arborescence

```text
timeflow-flutter/                          # racine du monorepo
├── CLAUDE.md                              # règles GLOBALES (conventions, workflow P→E→R)
├── README.md
├── melos.yaml                             # workspace + scripts (test, analyze, format)
├── analysis_options.yaml                  # lints partagés (very_good_analysis ou flutter_lints strict)
├── .gitignore
│
├── .claude/                               # ── CONFIG CLAUDE CODE (racine) ──
│   ├── settings.json                      # settings COMMITTÉS (deny rules, hooks…)
│   ├── settings.local.json                # settings PERSO (gitignored)
│   ├── agents/                            # sous-agents (le trio P→E→R + spécialistes)
│   │   ├── planner.md                     # PLANIFICATION
│   │   ├── executor.md                    # EXÉCUTION
│   │   ├── reviewer.md                    # RÉVISION
│   │   ├── flutter-ui-builder.md          # spécialiste écrans/animations Flutter
│   │   └── stats-verifier.md              # vérifie les calculs stats vs règles métier
│   ├── commands/                          # slash-commands réutilisables
│   │   ├── plan.md                        # /plan  <tâche>
│   │   ├── exec.md                        # /exec  <plan>
│   │   ├── review.md                      # /review
│   │   ├── task.md                        # /task  → enchaîne P→E→R
│   │   └── new-feature.md                 # scaffolding d'une feature
│   ├── skills/                            # skills PARTAGÉS (chargés depuis la racine)
│   │   ├── task-workflow/SKILL.md         # LE workflow Plan→Exec→Review
│   │   └── monorepo-conventions/SKILL.md  # règles Melos, où va quoi
│   ├── rules/                             # règles path-scopées
│   │   └── business-rules.md              # RG-01..RG-08 rappelées près du code métier
│   └── docs/                              # référentiels chargés à la demande
│       ├── data-model.md                  # schéma SQLite (drift) + modèles Dart
│       └── phases.md                      # planning 5 phases du CDC
│
├── apps/
│   ├── mobile/                            # ── APPLICATION FLUTTER (cœur phase 1→5) ──
│   │   ├── CLAUDE.md                      # conventions Flutter spécifiques
│   │   ├── .claude/
│   │   │   └── skills/
│   │   │       └── flutter-setup/SKILL.md # drift codegen, go_router, Riverpod, thème
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   └── lib/
│   │       ├── main.dart
│   │       ├── router/
│   │       │   └── app_router.dart         # go_router : Tab (Aujourd'hui / Stats / Historique)
│   │       ├── data/
│   │       │   ├── database.dart           # drift : ouverture DB, migrations
│   │       │   ├── tables.dart             # définition table `Activities`
│   │       │   └── activities_dao.dart     # implémente ActivityRepository (domain)
│   │       ├── screens/
│   │       │   ├── today_screen.dart
│   │       │   ├── stats_screen.dart
│   │       │   └── history_screen.dart
│   │       ├── sheets/
│   │       │   ├── new_activity_sheet.dart # bottom sheet
│   │       │   └── activity_detail_sheet.dart
│   │       ├── widgets/                    # UI pure, présentationnelle
│   │       │   ├── activity_card.dart
│   │       │   ├── category_chip.dart
│   │       │   ├── timeline.dart
│   │       │   ├── score_badge.dart
│   │       │   └── charts/
│   │       │       ├── category_pie_chart.dart   # fl_chart
│   │       │       └── daily_bar_chart.dart
│   │       ├── application/                # branchement state ↔ core (Riverpod)
│   │       │   ├── activities_provider.dart
│   │       │   └── stats_provider.dart
│   │       ├── theme/
│   │       │   └── app_theme.dart          # palette catégories (CDC), ThemeData
│   │       └── dev/
│   │           └── seeds.dart              # données fictives (test graphiques)
│   │   └── test/                           # widget tests + tests DAO (drift en mémoire)
│   │
│   └── api/                               # ── BACKEND FUTUR (squelette) ──
│       ├── CLAUDE.md
│       └── src/                            # placeholder — Node.js/Fastify prévu
│
├── packages/
│   ├── domain/                            # ── TYPES & CONTRATS PARTAGÉS (Dart pur) ──
│   │   ├── CLAUDE.md
│   │   ├── pubspec.yaml                    # sdk: dart — AUCUNE dépendance Flutter
│   │   ├── analysis_options.yaml
│   │   └── lib/
│   │       ├── timeflow_domain.dart        # export barrel unique
│   │       └── src/
│   │           ├── activity.dart           # Activity, CategoryId
│   │           ├── day_stats.dart          # DayStats, RangeStats
│   │           └── activity_repository.dart # interface (le "StoragePort")
│   │
│   ├── core/                              # ── LOGIQUE MÉTIER (pure, testée, Dart pur) ──
│   │   ├── CLAUDE.md
│   │   ├── pubspec.yaml                    # sdk: dart — dépend UNIQUEMENT de domain
│   │   ├── analysis_options.yaml
│   │   └── lib/
│   │       ├── timeflow_core.dart          # export barrel unique
│   │       └── src/
│   │           ├── activities/
│   │           │   ├── create_activity.dart    # RG-01, RG-03
│   │           │   ├── close_activity.dart     # RG-03
│   │           │   ├── validate_activity.dart  # RG-01, RG-02
│   │           │   └── duration.dart           # RG-04 (durationMin, cap 1440)
│   │           ├── stats/
│   │           │   ├── compute_day_stats.dart  # RG-05, RG-06
│   │           │   ├── productivity_score.dart # RG-06 (work/total, seuil 60%)
│   │           │   └── aggregate_range.dart    # RG-07 (7j / 30j glissants)
│   │           └── constants/
│   │               └── categories.dart         # 6 catégories (id, label, emoji, couleur)
│   │   └── test/                           # dart test — 100% sur la logique métier
│   │       ├── duration_test.dart
│   │       ├── productivity_score_test.dart
│   │       └── compute_day_stats_test.dart
│   │
│   └── sync_client/                       # ── CLIENT SYNC FUTUR (squelette) ──
│       ├── CLAUDE.md
│       ├── pubspec.yaml
│       └── lib/
│           └── src/
│               └── sync_repository.dart    # implémentation future d'ActivityRepository
│
└── docs/
    ├── cahier-des-charges.html            # le CDC Flutter (source de vérité)
    └── adr/                                # Architecture Decision Records
        ├── 0001-melos-monorepo.md
        └── 0002-drift-repository-abstraction.md
```

---

## 4. Le graphe de dépendances (règle d'or)

```
        ┌───────────────┐
        │    domain     │  (Dart pur, aucune dépendance runtime hors sdk)
        └───────┬───────┘
                │
        ┌───────▼───────┐
        │     core      │  (dépend de domain uniquement — Dart pur)
        └───┬───────┬───┘
            │       │
   ┌────────▼──┐  ┌─▼──────────┐
   │apps/mobile │  │sync_client │  (implémentent ActivityRepository)
   └───────────┘  └────────────┘
            ▲
   ┌────────┴──┐
   │ apps/api  │  (futur — dépend de core + domain via un port HTTP/JSON)
   └───────────┘
```

**Interdit** : `domain` et `core` ne dépendent **jamais** de `flutter`, `drift`, `sqlite3`, ni de `riverpod`.
La dépendance au stockage se fait **par inversion** : `domain` définit `ActivityRepository`, `apps/mobile` en fournit une implémentation drift à l'exécution.

```dart
// packages/domain/lib/src/activity_repository.dart
abstract interface class ActivityRepository {
  Stream<List<Activity>> watchByDate(String date);   // table `activities`, WHERE date = ?
  Future<void> save(Activity activity);
  Future<void> delete(String id);
  Future<RangeStats> aggregateRange(DateTime from, DateTime to); // RG-07, calcul SQL
}
```

Aujourd'hui : `ActivitiesDao` (drift, on-device). Demain : `SyncRepository` (sync_client) — **sans toucher au métier**.

---

## 5. Configuration Claude Code — le workflow Plan → Exec → Review

C'est le cœur de ta demande, inchangé dans son principe par rapport à la version React Native. Trois briques complémentaires garantissent la séquence sur **chaque** tâche.

### 5.1 Les 3 sous-agents (`.claude/agents/`)

| Agent | Rôle | Sortie | Ne fait PAS |
|-------|------|--------|-------------|
| `planner` | Explore le code concerné, identifie les règles métier touchées, découpe en étapes, **écrit le plan sur disque** (`.plans/<slug>.md`) | Un plan validé | N'écrit aucun code de prod |
| `executor` | Implémente **strictement** le plan approuvé, étape par étape, en respectant les CLAUDE.md du package | Le code + les tests | Ne redéfinit pas le périmètre ; s'il découvre un manque → repasse la main au planner |
| `reviewer` | Vérifie contre le plan ET les règles métier (RG-01..08), lance `melos run analyze test`, propose un diff de corrections | Rapport de revue + verdict | Ne « re-scope » pas la feature |

### 5.2 Les slash-commands (`.claude/commands/`)

- `/plan <description>` → invoque l'agent `planner`.
- `/exec` → invoque `executor` sur le dernier plan.
- `/review` → invoque `reviewer`.
- `/task <description>` → **orchestre les trois dans l'ordre**, avec un point d'approbation humain entre Plan et Exec (gate obligatoire).
- `/new-feature <nom>` → scaffolding (dossiers + fichiers vides + branche git).

### 5.3 Le skill `task-workflow`

Chargé automatiquement dès qu'une tâche de dev démarre, il rappelle la discipline P→E→R et interdit d'écrire du code avant plan approuvé.

### 5.4 Le hook de garde-fou

Un hook `PreToolUse` (dans `settings.json`) bloque les écritures de fichiers `.dart` (hors `*.g.dart` générés) tant qu'aucun plan approuvé n'existe pour la session — matérialise « pas d'exécution sans planification ».

---

## 6. Mapping Règles métier (CDC) → emplacement dans le code

| Règle | Description courte | Fichier propriétaire | Test |
|-------|--------------------|-----------------------|------|
| RG-01 | Titre + catégorie obligatoires | `core/src/activities/validate_activity.dart` | ✅ |
| RG-02 | Fin > début, durée min 1 min | `core/src/activities/validate_activity.dart` | ✅ |
| RG-03 | Activité « en cours » (endTime null) | `core/src/activities/create_activity.dart` + `close_activity.dart` | ✅ |
| RG-04 | Durée auto = fin − début, cap 1440 | `core/src/activities/duration.dart` | ✅ |
| RG-05 | Données par jour, colonne `date` indexée | `apps/mobile/lib/data/activities_dao.dart` | ✅ |
| RG-06 | Score = travail/total, seuil 60% | `core/src/stats/productivity_score.dart` | ✅ |
| RG-07 | Hebdo = 7j, mensuel = 30j glissants, agrégation SQL | `core/src/stats/aggregate_range.dart` + requête drift | ✅ |
| RG-08 | Édition/suppression (confirmation) | `apps/mobile/lib/data/activities_dao.dart` + UI sheet | ✅ |

> Les règles vivent **une seule fois**, dans `packages/core`. Le mobile ne les duplique jamais — il appelle `core` et persiste via le DAO.

---

## 7. Mapping Phases du CDC → séquence Claude Code

Chaque phase = une série de tâches, chacune passant par `/task` (Plan → Exec → Review).

| Phase CDC | Packages touchés | Tâches type |
|-----------|-------------------|-------------|
| **1 — Setup & Navigation** | `apps/mobile`, `.claude/*` | Init Flutter, go_router (Tab), thème, écrans vides |
| **2 — Base de données & Saisie** | `domain`, `core`, `apps/mobile` | `ActivityRepository`, schéma drift, `ActivitiesDao`, `createActivity`, NewActivitySheet, liste du jour (Stream) |
| **3 — Timeline & Édition** | `core`, `apps/mobile` | Timeline, activité en cours (Ticker), édition/suppression (RG-08) |
| **4 — Statistiques** | `core`, `apps/mobile` | `computeDayStats`, `productivityScore`, `aggregateRange` (SQL), Pie + Bar fl_chart, seeds |
| **5 — Polish & Animations** | `apps/mobile` | Animations Flutter (implicites/explicites), bottom sheet, micro-interactions |

---

## 8. Fichiers de configuration livrés

Les fichiers suivants sont fournis prêts à l'emploi dans le dossier `.claude/` et à la racine :
`CLAUDE.md` (racine + par package), `settings.json`, les 5 agents, les 5 commandes,
les 2 skills partagés, la règle métier path-scopée, `melos.yaml`, `analysis_options.yaml`
et les `pubspec.yaml` clés (squelettes).

Voir le paquet de fichiers joint.
