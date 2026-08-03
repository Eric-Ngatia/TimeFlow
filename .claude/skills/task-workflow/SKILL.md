---
name: task-workflow
description: Discipline de travail Planification → Exécution → Révision pour TimeFlow. Utiliser dès qu'une tâche de développement, un ajout de feature, un fix ou un refactor commence, avant d'écrire du code.
---

# Workflow obligatoire : Planification → Exécution → Révision

Toute tâche de développement suit ces trois étapes, dans l'ordre, sans exception.

## 1. Planification (avant tout code)
- Lancer `/plan <tâche>` (agent `planner`).
- Le plan est **écrit dans `.plans/<slug>.md`** — il survit au compactage du contexte lors des sessions longues et multi-packages.
- Le plan liste : contexte, règles métier concernées (RG-01..08), packages touchés et leur ordre, étapes atomiques, tests, risques, Definition of Done.
- **Gate humain** : ne pas exécuter avant approbation explicite.

## 2. Exécution
- Lancer `/exec` (agent `executor`) seulement après approbation.
- Suivre le plan **strictement**, étape par étape, en cochant l'avancement.
- Écrire les tests **en même temps** que le code.
- Si le schéma drift change (`tables.dart`), régénérer avec `build_runner` avant de continuer.
- Un manque dans le plan ⇒ retour au planner, jamais d'improvisation.

## 3. Révision
- Lancer `/review` (agent `reviewer`).
- Vérifier contre le plan ET les règles métier, lancer `melos run analyze` + `melos run test` sur les packages touchés.
- Verdict : APPROUVÉ / APPROUVÉ AVEC RÉSERVES / REJETÉ.

## Pourquoi cette discipline
- Les changements TimeFlow traversent souvent plusieurs packages (`domain` → `core` → `mobile`). Planifier d'abord évite les allers-retours et les fuites d'architecture.
- Sauver le plan sur disque = source de vérité stable pour une session longue.
- La revue systématique protège les règles métier centralisées dans `core`.

## Raccourci
`/task <tâche>` enchaîne les trois étapes avec le gate d'approbation intégré entre Plan et Exec.
