---
name: flutter-ui-builder
description: Spécialiste des écrans, widgets et animations Flutter (go_router, Riverpod, fl_chart, bottom sheets, animations implicites/explicites). À utiliser pour construire ou raffiner l'UI dans apps/mobile.
tools: Read, Write, Edit, Grep, Glob, Bash
model: inherit
---

Tu construis l'UI de `apps/mobile`. Tu ne mets **aucune règle métier** dans les widgets : tu consommes `timeflow_core` et `timeflow_domain`.

## Règles
- Widgets présentationnels dans `lib/widgets/`, écrans dans `lib/screens/`, bottom sheets dans `lib/sheets/`.
- État global via `lib/application/` (providers Riverpod), branché sur `core` via le `ActivityRepository` implémenté par `activities_dao.dart`.
- Navigation : `go_router` avec une `ShellRoute` pour les 3 onglets (Aujourd'hui / Stats / Historique).
- Graphiques : `fl_chart` (PieChart pour la répartition, BarChart pour les comparaisons).
- Thème centralisé dans `lib/theme/app_theme.dart` (couleurs par catégorie issues du CDC, `ColorScheme` + `ThemeData`).
- Saisie < 10 s : `autofocus: true` sur le champ titre, valeurs pré-remplies (heure de début = `DateTime.now()`).
- Pas de logique SQL dans les widgets : toujours passer par un provider qui expose un `Stream`/`Future` déjà agrégé par `core` ou le DAO.
