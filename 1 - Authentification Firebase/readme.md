**Mise en place complète d'un chart Helm** pour déployer une **fonctionnalité d'authentification Firebase** en environnement Kubernetes. L’objectif est de **configurer Firebase côté client** (souvent dans une application front), de gérer **les secrets** côté back, et de **déployer un microservice** (comme un proxy ou une API Gateway) qui exploite l’authentification Firebase.

---

# 📊 Chart Helm – Authentification Firebase

---

## 🔹 1. **Structure du Chart Helm**

```
firebase-auth-chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── secret.yaml
```

---

## 🗂️ 2. **Chart.yaml**

```yaml
apiVersion: v2
name: firebase-auth-chart
description: Helm chart pour déployer un service d'authentification basé sur Firebase
type: application
version: 0.1.0
appVersion: "1.0.0"
```

> 🔍 Ce fichier décrit le chart Helm. Il contient le nom, la version, et le type de déploiement (`application`).

---

## ⚙️ 3. **values.yaml**

```yaml
image:
  repository: myregistry/firebase-auth-service
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

firebase:
  apiKey: YOUR_FIREBASE_API_KEY
  authDomain: your-app.firebaseapp.com
  projectId: your-app
  storageBucket: your-app.appspot.com
  messagingSenderId: YOUR_SENDER_ID
  appId: YOUR_APP_ID

replicaCount: 1
```

> 🎛️ Ce fichier est le **fichier de configuration** de votre chart. Il contient :

* les variables liées à l’image Docker de votre service
* les paramètres Firebase (informations sensibles, mais visibles ici à des fins de clarté)
* le nombre de réplicas, le type de service, etc.

---

## 🛠️ 4. **templates/deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-firebase-auth
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: firebase-auth
  template:
    metadata:
      labels:
        app: firebase-auth
    spec:
      containers:
        - name: firebase-auth
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: 80
          envFrom:
            - configMapRef:
                name: {{ .Release.Name }}-firebase-config
```

> 🔍 Ce fichier crée un **Deployment** Kubernetes :

* il déploie votre service Firebase Auth
* il charge les variables d’environnement depuis un `ConfigMap`

---

## 🔐 5. **templates/configmap.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-firebase-config
data:
  FIREBASE_API_KEY: {{ .Values.firebase.apiKey }}
  FIREBASE_AUTH_DOMAIN: {{ .Values.firebase.authDomain }}
  FIREBASE_PROJECT_ID: {{ .Values.firebase.projectId }}
  FIREBASE_STORAGE_BUCKET: {{ .Values.firebase.storageBucket }}
  FIREBASE_MESSAGING_SENDER_ID: {{ .Values.firebase.messagingSenderId }}
  FIREBASE_APP_ID: {{ .Values.firebase.appId }}
```

> 📦 Ce `ConfigMap` expose les variables Firebase au conteneur. En production, il est recommandé de stocker les **informations sensibles dans des `Secrets`**.

---

## 🌐 6. **templates/service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-firebase-auth
spec:
  type: {{ .Values.service.type }}
  selector:
    app: firebase-auth
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: 80
```

> Ce `Service` expose le pod dans le cluster (en mode interne ou LoadBalancer selon besoin).

---

## 🛡️ 7. (Optionnel) **templates/secret.yaml**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-firebase-secret
type: Opaque
data:
  FIREBASE_API_KEY: {{ .Values.firebase.apiKey | b64enc }}
```

> 🔐 Alternative sécurisée au `ConfigMap`, si vous devez gérer des secrets sensibles.

---

## 🚀 8. **Installation du Chart**

```bash
helm install firebase-auth ./firebase-auth-chart --values values.yaml
```

Ou pour une mise à jour :

```bash
helm upgrade firebase-auth ./firebase-auth-chart --values values.yaml
```

---

## 🧪 9. **Test Firebase dans l'app**

Votre application (front ou back) pourra maintenant utiliser Firebase ainsi :

```js
import { initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  ...
};

const app = initializeApp(firebaseConfig);
```

> Assurez-vous que vos variables d’environnement sont injectées dans l’environnement de votre runtime (Node.js, navigateur, etc.).

---

## 🧠 Résumé

| Élément Helm           | Rôle                                                        |
| ---------------------- | ----------------------------------------------------------- |
| `Chart.yaml`           | Métadonnées du chart                                        |
| `values.yaml`          | Paramètres personnalisables                                 |
| `deployment.yaml`      | Déploie l’image Docker de votre service Firebase Auth       |
| `configmap.yaml`       | Fournit les variables d’environnement liées à Firebase      |
| `secret.yaml` (option) | Permet de sécuriser les infos sensibles (API key, etc.)     |
| `service.yaml`         | Expose le service pour qu’il soit joignable dans le cluster |

---

Souhaitez-vous que je vous propose un **exemple concret de microservice Express.js ou Next.js API** qui utilise ce chart pour authentifier les utilisateurs avec un token Firebase ?

