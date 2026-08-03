---
description: Règles métier TimeFlow (RG-01..RG-08). Référence près du code qui les implémente.
paths:
  - "packages/core/**"
  - "apps/mobile/lib/data/**"
  - "apps/mobile/lib/sheets/**"
---

# Règles métier — source de vérité

- **RG-01** — Titre + catégorie obligatoires. Heure de début pré-remplie (= maintenant) mais modifiable.
- **RG-02** — Heure de fin > heure de début. Durée minimale 1 minute. Sinon : erreur + sauvegarde bloquée.
- **RG-03** — Activité « en cours » autorisée (`endTime` = null). Indicateur visuel, clôturable à tout moment.
- **RG-04** — `durationMin` = (fin − début) en minutes, arrondi. Total journalier ≤ 1440 min.
- **RG-05** — Données par jour. Colonne `date` (TEXT, `YYYY-MM-DD`) indexée dans la table `activities`.
- **RG-06** — Score de productivité = temps `work` / total journalier (%). ≥ 60 % ⇒ journée productive. Badge coloré.
- **RG-07** — Bilan hebdo = 7 derniers jours glissants ; mensuel = 30. Agrégation **via requête SQL** (drift, `SUM` + `GROUP BY`), aucun pré-calcul stocké.
- **RG-08** — Toute activité éditable (titre, catégorie, heures) et supprimable (avec confirmation ; suppression définitive).

> Ces règles sont implémentées **une seule fois**, dans `packages/core`. L'UI ne les redéfinit jamais — elle appelle `core` puis persiste via le DAO drift.
