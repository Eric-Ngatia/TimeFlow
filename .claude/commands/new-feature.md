---
description: Scaffolder une nouvelle feature (dossiers + branche git)
argument-hint: <nom-feature>
---

Prépare le terrain pour la feature « $ARGUMENTS » :
1. Crée la branche `git checkout -b feat/$ARGUMENTS`.
2. Propose l'emplacement des fichiers selon l'architecture (core d'abord si règle métier, mobile ensuite pour l'UI).
3. NE code pas encore : enchaîne sur `/plan $ARGUMENTS`.
