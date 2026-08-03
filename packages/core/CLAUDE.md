# timeflow_core — Logique métier

Logique pure : validation, durées, stats, score de productivité.

## Règles
- Dépend UNIQUEMENT de `timeflow_domain` (chemin relatif `path: ../domain`). **Aucun import de flutter/drift/riverpod.**
- L'accès aux données passe par l'interface `ActivityRepository` (injectée), jamais par une implémentation concrète.
- Implémente les règles RG-01..RG-08 (voir `.claude/rules/business-rules.md`) — une seule fois, ici.
- Tout export via le barrel `lib/timeflow_core.dart`. Fonctions pures et testées (`dart test`, viser 100%).

## Commandes
- `melos run test:core`
- `melos run analyze --scope=timeflow_core`
