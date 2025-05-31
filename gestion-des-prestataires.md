## Pourquoi commencer le projet par la gestion des prestataires

Le choix de la fonctionnalité initiale à développer est stratégique, car il influence :

* La structure technique de l’application
* L’expérience utilisateur dès le MVP
* La validation rapide du besoin marché

🔍 Rappel : fonctionnalités principales de PrestaEvents

* Gestion des prestataires (inscription, profils, spécialités, etc.)
* Système de géolocalisation des prestataires
* Recherche et filtrage
* Agenda des disponibilités
* Réservation de prestataires
* Notation/commentaires
* Interface client (utilisateur) et interface prestataire
* Services variés : traiteurs, photographes, animateurs, etc.

🎯 Fonctionnalité à développer en premier : gestion des prestataires

Pourquoi commencer par là ?

1. Fonction centrale
   C’est la base même du modèle : sans prestataires, aucune recherche, réservation, notation, géolocalisation ou agenda n’a de sens.

2. Structuration de la donnée
   Le modèle des prestataires (nom, spécialité, zone de couverture, services offerts, coordonnées, etc.) est transversal à toute la plateforme.

3. Point d’entrée pour la double interface
   Cette fonctionnalité permet de construire deux parcours utilisateurs :

   * Inscription / gestion de compte côté prestataire
   * Découverte et consultation côté client

4. Test de marché immédiat
   Tu peux commencer à inviter des prestataires à s’inscrire, même si la réservation ou le paiement ne sont pas encore implémentés. Cela permet de tester l’intérêt de l’offre côté offreur.

5. Scalabilité du backend
   Elle permet de tester les fondations techniques (authentification, base de données, API REST/GraphQL, hébergement, CI/CD, Helm, namespace Kubernetes…).

🚀 Étapes techniques proposées pour cette première fonctionnalité (dans un MVP)

1. Authentification & création de compte (prestataire uniquement)
2. Création du profil prestataire

   * Données générales (nom, service, description)
   * Zone d’activité (code postal, rayon)
   * Médias (photo/logo, images de réalisations)
3. Back-office de gestion du profil (modification, suppression)
4. API publique de consultation des prestataires (pour les futurs utilisateurs)
5. Géolocalisation basique (via rayon autour d’un point ou code postal)
6. Déploiement Helm (namespace auth-namespace et provider-namespace)

💡 Conseil produit :

Avant d’implémenter la réservation ou le calendrier, assure-toi que l’on peut facilement :

* Voir les prestataires autour de soi
* Filtrer par type de service
* Contacter un prestataire

Cela suffit à démontrer la valeur de PrestaEvents dès la V0.


## Voici une proposition technique très détaillée pour la mise en place de la fonctionnalité Gestion des prestataires dans PrestaEvents, structurée selon une architecture microservices, utilisant Helm, Kubernetes (pods, namespaces, labels), et respectant les principes de déploiement évolutif, modulaire et maintenable.

🧩 Objectif de cette phase

Mettre en place un ensemble cohérent de services (Backend/API, base de données, fichiers médias, validation, etc.) pour permettre l’inscription, la gestion, la mise à jour et la consultation des profils de prestataires. Cette fonctionnalité doit être autonome, isolée, extensible et résiliente.

📐 Architecture logique — Segmentation en microservices

Nom du namespace : provider-namespace

Microservices proposés pour "Gestion des prestataires" :

| Microservice               | Description                                                             |
| -------------------------- | ----------------------------------------------------------------------- |
| provider-api               | Service principal Node.js/NestJS/Express REST ou GraphQL                |
| provider-db                | Base de données PostgreSQL ou MongoDB dédiée aux prestataires           |
| provider-media             | Service de gestion des médias (upload, resize, CDN), ex: MinIO/S3       |
| provider-validator         | Service de validation documentaire et catégorielle (OCR, règles métier) |
| provider-notifier (option) | Microservice d’envoi d’emails lors de validation ou mise à jour         |
| provider-gateway (option)  | API Gateway (si architecture nécessite un point d’entrée global)        |

📦 Helm Chart – Structure proposée

📁 charts/provider/

├── Chart.yaml
├── values.yaml
├── templates/
│   ├── namespace.yaml
│   ├── deployment-api.yaml
│   ├── deployment-db.yaml
│   ├── deployment-media.yaml
│   ├── service-api.yaml
│   ├── configmap.yaml
│   ├── ingress.yaml
│   └── secrets.yaml

<img width="237" alt="Capture d’écran 2025-05-31 à 19 32 43" src="https://github.com/user-attachments/assets/7f513209-7fe4-40e5-95bc-57b4d4346906" />


🌐 Détail par composant (avec recommandations Kubernetes)

1. provider-api (API REST/GraphQL)

* Langage : TypeScript (NestJS ou Express)

* Endpoints : CRUD prestataires, catégories, zone géographique

* DB connection (via env injecté via configMap + secret)

* Labels Kubernetes :

  labels:
  app: provider-api
  tier: backend
  version: v1

* Helm values.yaml :

  image:
  repository: registry.gitlab.com/prestaevents/provider-api
  tag: "1.0.0"
  service:
  type: ClusterIP
  port: 8080

* Déploiement :

  replicas: 2 (min)
  readinessProbe: /health
  livenessProbe: /health

2. provider-db (PostgreSQL)

* Image officielle Postgres (ou MongoDB selon techno)

* PV / PVC avec StorageClass dynamique

* Secrets via .Values.postgres.password

* Helm :

  persistence:
  enabled: true
  size: 5Gi
  resources:
  requests:
  memory: "256Mi"
  cpu: "250m"

3. provider-media

* Objectifs : gérer les fichiers uploadés (logos, images de prestations)

* Techno : MinIO, ou microservice Node/Express + multer + S3 compatible

* Volume mounted pour persistance (ou remote storage)

* Public URL via ingress

* Labels :

  labels:
  app: provider-media
  tier: storage

4. provider-validator (optionnel MVP, utile V1+)

* Objectif : service indépendant pour :

  * OCR ou validation de pièce
  * Normalisation des données (code postal, nom…)

* Intérêt : découpler la logique métier métier "lente" ou asynchrone

* Peut être appelé par provider-api via HTTP/gRPC ou events (Kafka/RabbitMQ)

5. provider-notifier (facultatif pour MVP)

* Email via Sendgrid, SMTP ou service externe
* Déployé sous forme de cronJob ou microservice
* Envois après inscription, modification ou validation

🔁 Communication entre services

* API REST interne (ClusterIP services)
* Ou RabbitMQ/Kafka pour les events (future V2+)
* Utilisation d’un service mesh (istio/Linkerd) optionnelle

📡 Helm et segmentation par namespace

Chaque fonctionnalité majeure (ex: auth, booking, provider) est déployée dans son propre namespace :

* Avantages :

  ✅ Isolation logique
  ✅ Gestion des quotas par namespace
  ✅ Sécurité réseau (NetworkPolicy)
  ✅ Déploiement contrôlé via Helm par chart

* Exemple de Helm values :

  namespace: provider-namespace
  ingress:
  enabled: true
  host: provider.dev.prestaevents.com
  tls: true

🔖 Exemple de labels Kubernetes

Appliqués dans templates/deployment.yaml :

metadata:
labels:
app.kubernetes.io/name: provider-api
app.kubernetes.io/component: api
app.kubernetes.io/part-of: prestaevents
app.kubernetes.io/version: v1
environment: dev

📈 Observabilité (proposée dès V1)

* Prometheus annotations dans les pods
* Liveness/readiness probes
* Stack Grafana + Loki pour logs + metrics
* Alertes email/Slack sur erreurs critiques

🔐 Sécurité

* Secrets (DB, JWT, API keys) via Helm + Kubernetes Secrets
* RBAC minimum sur le namespace
* NetworkPolicy pour empêcher appels extérieurs non autorisés

📊 CI/CD Helm (déjà proposé précédemment)

Chaque push vers charts/provider déclenche :

* helm lint
* helm upgrade --install provider charts/provider
* sur le cluster associé (namespace : provider-namespace)

🧪 Tests (recommandés)

* Test unitaire : microservice api
* Test d’intégration (Postman/Newman ou k6 pour API provider)
* Helm test pour vérifier pod health / endpoints exposés

📘 Résumé (stack complète)

* Namespace : provider-namespace
* Charts : Helm charts/provider
* Pods : provider-api, provider-db, provider-media, validator
* Services : ClusterIP internes, Ingress API public
* GitOps : Helm chart versionné et déployé via CI/CD
* Sécurité : secrets, RBAC, probes
* Observabilité : probes, métriques, logs

Souhaites-tu que je t’exporte cette architecture technique au format Markdown téléchargeable ou la convertir en diagramme visuel ?

