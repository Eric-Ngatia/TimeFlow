# ADR 0002 — ActivityRepository comme port d'abstraction du stockage

## Contexte
L'app doit fonctionner 100% offline avec une vraie base de données (au lieu d'un stockage clé/valeur type AsyncStorage), tout en restant ouverte à une synchronisation serveur future.

## Décision
Définir l'interface `ActivityRepository` dans `packages/domain` (Dart pur). `apps/mobile` fournit `ActivitiesDao` comme implémentation drift/SQLite. Une future implémentation `SyncRepository` (`packages/sync_client`) pourra la remplacer ou la compléter sans changer `packages/core`.

## Conséquences
- `packages/core` ne connaît jamais SQLite, drift, ni le schéma de table concret — il manipule des `Activity`/`DayStats` et appelle l'interface.
- Les agrégations (bilans hebdo/mensuel, RG-07) sont écrites comme des méthodes de l'interface (`aggregateRange`) et implémentées en SQL côté drift — pas en boucle Dart après un chargement complet.
- Coût : une couche d'indirection supplémentaire par rapport à un accès direct à drift depuis les providers Riverpod. Jugé justifié vu l'historique du projet (déjà pensé pour un backend futur côté React Native) et la taille modeste du domaine (une seule table pour l'instant).
