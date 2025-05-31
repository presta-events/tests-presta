## - Chaque fonctionnalité doit être délimitée par un namespace

## - Liste des fonctionnalités :

### Structure des Namespaces

| Namespace              | Fonction principale                            | Services / Pods                                 |
|------------------------|-----------------------------------------------|-------------------------------------------------|
| auth-namespace         | Authentification / sessions                    | auth-service, token-service, session-store      |
| user-namespace         | Gestion des utilisateurs clients               | user-service, profile-service                   |
| provider-namespace     | Gestion des prestataires                       | provider-service, portfolio-service             |
| booking-namespace      | Réservations, disponibilités                   | booking-service, availability-service           |
| messaging-namespace    | Messagerie interne                             | message-service, notification-hub               |
| payment-namespace      | Paiements, acomptes                            | payment-service, billing-service                |
| search-namespace       | Recherche, filtres, géolocalisation            | search-service, elasticsearch-pod               |
| rating-namespace       | Notations, commentaires                        | review-service, moderation-service              |
| media-namespace        | Uploads, CDN, stockage cloud                   | media-uploader, CDN-proxy                       |
| blog-namespace         | Blog, SEO, contenu inspirationnel              | cms-service, article-service                    |
| notification-namespace | Emails, push, rappels                          | email-service, push-service, scheduler          |
| analytics-namespace    | Statistiques, tableaux de bord                 | analytics-service, metrics-service              |
| admin-namespace        | Gestion plateforme, modération                 | admin-ui, admin-api, audit-service              |
| gateway-namespace      | API Gateway / Ingress                          | API Gateway (Kong, Traefik), cert-manager       |
| shared-namespace       | Services transversaux                          | PostgreSQL, Redis, Prometheus, Loki, Grafana    |


## Pour la mise en place d'un namespace, un chart Helm doit être crée
