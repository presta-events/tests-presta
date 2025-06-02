Parfait. Voici une réponse détaillée en deux grandes parties pour répondre à votre besoin d’**intégration avec Kubernetes via Helm**, avec une **image Docker pour le microservice Next.js** utilisant l’authentification Firebase.

---

# ⚙️ Intégration avec Kubernetes / Helm Chart pour microservice Next.js avec Firebase Auth

---

## 🧱 PARTIE 1 – Création d'une image Docker pour le microservice

### 📄 `Dockerfile` minimal pour Next.js 14 avec App Router

```Dockerfile
# Étape 1 : build
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Étape 2 : image finale
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app/package.json ./
COPY --from=builder /app/.next .next
COPY --from=builder /app/public public
COPY --from=builder /app/node_modules node_modules

EXPOSE 3000

CMD ["npx", "next", "start"]
```

### 📁 Fichier `.dockerignore`

```
node_modules
.next
.git
Dockerfile
.env.local
```

### ✅ Construction et test local

```bash
docker build -t firebase-next-service .
docker run -p 3000:3000 --env-file .env.local firebase-next-service
```

---

## 🐳 PARTIE 2 – Déploiement Kubernetes avec Helm

### 📁 Arborescence Helm

```
charts/
└── firebase-auth-service/
    ├── templates/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── ingress.yaml
    │   └── secret.yaml
    ├── Chart.yaml
    └── values.yaml
```

---

### 🧾 `Chart.yaml`

```yaml
apiVersion: v2
name: firebase-auth-service
description: Microservice Next.js authentifié par Firebase
version: 0.1.0
appVersion: "1.0"
```

---

### 🧾 `values.yaml`

```yaml
image:
  repository: ghcr.io/votre-utilisateur/firebase-next-service
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 3000

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: next-auth.mondomaine.local
      paths:
        - path: /
          pathType: Prefix

env:
  FIREBASE_PROJECT_ID: "your-firebase-project-id"
  FIREBASE_CLIENT_EMAIL: "your-client-email@project.iam.gserviceaccount.com"
  FIREBASE_PRIVATE_KEY: |
    -----BEGIN PRIVATE KEY-----
    ABCDEF123456...
    -----END PRIVATE KEY-----
```

---

### 🧾 `templates/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: firebase-auth
spec:
  replicas: 1
  selector:
    matchLabels:
      app: firebase-auth
  template:
    metadata:
      labels:
        app: firebase-auth
    spec:
      containers:
        - name: next-app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: 3000
          env:
            - name: FIREBASE_PROJECT_ID
              value: "{{ .Values.env.FIREBASE_PROJECT_ID }}"
            - name: FIREBASE_CLIENT_EMAIL
              value: "{{ .Values.env.FIREBASE_CLIENT_EMAIL }}"
            - name: FIREBASE_PRIVATE_KEY
              value: "{{ .Values.env.FIREBASE_PRIVATE_KEY | b64enc | quote }}"
```

---

### 🧾 `templates/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: firebase-auth
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 3000
  selector:
    app: firebase-auth
```

---

### 🧾 `templates/ingress.yaml` (facultatif)

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: firebase-auth-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: {{ .Values.ingress.className }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: firebase-auth
                port:
                  number: 3000
          {{- end }}
    {{- end }}
{{- end }}
```

---

### 🚀 Commande `helm install` avec personnalisation

```bash
helm install firebase-auth charts/firebase-auth-service \
  --set image.repository=ghcr.io/votre-utilisateur/firebase-next-service \
  --set image.tag=latest \
  --set env.FIREBASE_PROJECT_ID=your-firebase-project-id \
  --set env.FIREBASE_CLIENT_EMAIL=your-client-email@project.iam.gserviceaccount.com \
  --set-file env.FIREBASE_PRIVATE_KEY=secrets/private_key.pem
```

---

## 📌 Résumé

| Élément              | Description                                           |
| -------------------- | ----------------------------------------------------- |
| Dockerfile           | Crée une image Next.js avec App Router                |
| Helm Chart           | Déploie le service sur Kubernetes                     |
| `firebase-admin` SDK | Vérifie le JWT côté serveur                           |
| `helm install`       | Installe le microservice en injectant les credentials |
| `Ingress`            | Rend l’API accessible de l’extérieur                  |

Souhaitez-vous que je vous prépare aussi :

* Un **fichier `private_key.pem` de test** ?
* Une **configuration GitHub Actions** pour automatiser la build et le push vers Docker Hub ou GHCR ?
* Un exemple de **client React avec Firebase Auth** pour générer et envoyer le token à cet endpoint ?

Je peux fournir tout cela étape par étape.

