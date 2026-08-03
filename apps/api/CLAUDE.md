# api — Backend futur (SQUELETTE)

Ne pas développer sans demande explicite. Matérialise la frontière serveur pour le mode sync futur.
Stack envisagée : Node.js + Fastify + PostgreSQL (cohérente avec tes autres projets), exposant un contrat JSON qui reflète `Activity`/`DayStats` de `timeflow_domain`.
Réutilisera les règles métier existantes côté client (pas de duplication des RG — le serveur ne fait que persister/synchroniser, `timeflow_core` reste la source de vérité des règles).
