# ADR 0001 — Melos comme gestionnaire de monorepo

## Contexte
Le projet migre de React Native (pnpm workspaces + Turborepo) vers Flutter. On veut conserver la séparation métier/UI qui avait fait ses preuves (`packages/core` indépendant du framework).

## Décision
Utiliser **Melos** pour gérer plusieurs packages Dart/Flutter (`apps/*`, `packages/*`) dans un seul dépôt Git.

## Conséquences
- `domain` et `core` restent des packages Dart purs (`sdk: dart`), ce qui interdit mécaniquement toute dépendance à Flutter/drift/riverpod — pas seulement par convention documentée.
- Les commandes (`analyze`, `test`, `build_runner`) sont scriptées une fois dans `melos.yaml` et s'appliquent à tout le repo ou à un package ciblé.
- Alternative écartée : un simple `flutter create` monolithique — plus rapide à démarrer, mais perd la frontière dure entre métier et UI, et rend un futur package de sync plus coûteux à extraire.
