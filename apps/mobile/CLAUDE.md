# mobile — Application Flutter

Cœur du produit. Consomme `timeflow_core` et `timeflow_domain`. **Ne réimplémente aucune règle métier.**

## Structure
- `screens/` écrans · `sheets/` bottom sheets · `widgets/` UI pure (dont `widgets/charts/` pour fl_chart) · `application/` state (providers Riverpod) · `data/` implémentation drift de `ActivityRepository` · `theme/` design system · `router/` go_router.

## Points d'attention (CDC)
- Schéma drift dans `data/tables.dart` : toute modif nécessite `dart run build_runner build --delete-conflicting-outputs` avant de compiler.
- Dates en ISO 8601 local, pas d'UTC.
- Les stats/agrégations passent par une requête drift (`ActivitiesDao.aggregateRange`), jamais par un chargement complet en mémoire.
- `dev/seeds.dart` pour tester les graphiques sans saisie manuelle (dès phase 4) — insère via le DAO, pas de SQL brut à la main.

## Commandes
- `flutter run` (depuis `apps/mobile`)
- `dart run build_runner build --delete-conflicting-outputs` (codegen drift après modif de `tables.dart`)
- `flutter test`
