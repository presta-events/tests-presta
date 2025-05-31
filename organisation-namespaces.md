from pathlib import Path

# Contenu du fichier Markdown structuré
markdown_content = """# 📦 PrestaEvents – Architecture Kubernetes détaillée

## 🎯 Objectif

Mettre en œuvre une architecture Kubernetes modulaire et scalable pour l'application PrestaEvents, en isolant les fonctionnalités principales dans des namespaces distincts et en encapsulant les services dans des pods indépendants.

---

## 🧠 Philosophie d’architecture

Chaque namespace représente un domaine fonctionnel. Chaque service associé est isolé dans un pod (ou plusieurs) selon les besoins. Cette structure permet :

- Une indépendance des cycles de vie
- Une sécurité renforcée via RBAC & NetworkPolicies
- Une évolutivité horizontale spécifique à chaque domaine
- Une organisation claire du cluster

---

## 🧱 Structure des Namespaces

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

---

## 🔒 Sécurité & Observabilité

- RBAC et NetworkPolicies par namespace
- PodSecurityStandards / mTLS (mutual TLS)
- Monitoring : Prometheus, Grafana, Alertmanager
- Logs : Loki, Fluentbit
- Tracing : OpenTelemetry + Jaeger

---

## ⚙️ CI/CD & GitOps

- CI avec GitHub Actions / GitLab CI :
  - Linting, tests, build, push vers GHCR/ECR
- Déploiement automatisé via Helm ou Kustomize
- GitOps avec ArgoCD ou FluxCD

---

## 📁 Structure recommandée des Charts Helm

```text
/charts
  ├── auth/
  ├── user/
  ├── booking/
  ├── gateway/
  └── shared/
