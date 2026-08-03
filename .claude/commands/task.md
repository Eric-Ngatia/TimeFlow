---
description: Cycle complet Planification → Exécution → Révision pour une tâche
argument-hint: <description de la tâche>
---

Exécute le cycle complet TimeFlow pour : $ARGUMENTS

1. **Planification** — agent `planner` : écris le plan dans `.plans/` puis **STOP** et demande mon approbation. N'enchaîne pas sans mon feu vert.
2. **Exécution** — après approbation, agent `executor` : implémente le plan + tests.
3. **Révision** — agent `reviewer` : vérifie, teste, rends le verdict.

Respecte le gate d'approbation entre l'étape 1 et l'étape 2.
