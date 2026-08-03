# Planning 5 phases (CDC)

1. **Setup & Navigation** (S1) — Init Flutter, structure de dossiers, `go_router` (Tab), écrans vides, `ThemeData`.
2. **Base de données & Saisie** (S2) — `ActivityRepository` (domain), schéma drift + `ActivitiesDao`, `createActivity`, NewActivitySheet, liste du jour via `Stream`.
3. **Timeline & Édition** (S3) — Timeline, activité en cours (Ticker/Timer), édition/suppression (RG-08), animations de base.
4. **Statistiques** (S4) — `computeDayStats`, `productivityScore`, `aggregateRange` (requête SQL), Pie + Bar (fl_chart), seeds.
5. **Polish & Animations** (S5) — Animations Flutter (implicites/explicites), bottom sheet, micro-interactions, finitions.

Chaque phase = suite de tâches, chacune via `/task` (Plan -> Exec -> Review).
