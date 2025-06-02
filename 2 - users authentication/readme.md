Voici un **exemple complet et concret d’un microservice basé sur Next.js 14 (avec App Router et `route.ts`)** qui exploite **l’authentification Firebase** en se basant sur un **token JWT ID Firebase** passé par le client. Ce service peut être couplé avec le **chart Helm d’authentification Firebase** décrit précédemment pour un déploiement en production.

---

# ⚙️ Microservice Next.js 14 API – Authentification avec Firebase

---

## 📁 Structure minimale

```
app/
└── api/
    └── protected/
        └── route.ts       ← Endpoint protégé par Firebase
firebase/
└── admin.ts              ← Initialisation Admin SDK
.env.local                ← Variables d’environnement
```

---

## 1. 🧪 Dépendances à installer

Installez Firebase Admin SDK :

```bash
npm install firebase-admin
```

---

## 2. 🔐 Variables d’environnement `.env.local`

> Vous pouvez injecter ces secrets via `ConfigMap` ou `Secret` Kubernetes si vous utilisez Helm.

```
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=your-client-email@your-firebase-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nXXX\n-----END PRIVATE KEY-----\n"
```

⚠️ `FIREBASE_PRIVATE_KEY` doit respecter les sauts de ligne avec `\n`.

---

## 3. 🧩 `firebase/admin.ts` – Initialisation Firebase Admin SDK

```ts
import { initializeApp, cert, getApps } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

export const adminAuth = getAuth();
```

> ✅ Ce module initialise le SDK Admin Firebase pour pouvoir vérifier les tokens ID.

---

## 4. 🧱 Middleware facultatif (si vous préférez une approche centralisée)

```ts
// middleware.ts (optionnel)
import { NextRequest, NextResponse } from 'next/server';
import { adminAuth } from './firebase/admin';

export async function middleware(req: NextRequest) {
  const idToken = req.headers.get('authorization')?.replace('Bearer ', '');

  if (!idToken) {
    return NextResponse.json({ error: 'Non autorisé' }, { status: 401 });
  }

  try {
    await adminAuth.verifyIdToken(idToken);
    return NextResponse.next();
  } catch (err) {
    return NextResponse.json({ error: 'Token invalide' }, { status: 403 });
  }
}
```

---

## 5. 🧩 `app/api/protected/route.ts` – API sécurisée par Firebase

```ts
import { NextRequest, NextResponse } from "next/server";
import { adminAuth } from "@/firebase/admin";

export async function GET(req: NextRequest) {
  const authHeader = req.headers.get("authorization");
  const token = authHeader?.split("Bearer ")[1];

  if (!token) {
    return NextResponse.json({ error: "Token manquant" }, { status: 401 });
  }

  try {
    const decodedToken = await adminAuth.verifyIdToken(token);
    const uid = decodedToken.uid;

    return NextResponse.json({
      message: "Accès autorisé",
      uid,
      email: decodedToken.email,
    });
  } catch (error) {
    return NextResponse.json({ error: "Token invalide" }, { status: 403 });
  }
}
```

---

## 6. 🧪 Exemple de requête côté client

```ts
const token = await firebase.auth().currentUser?.getIdToken();

const res = await fetch("/api/protected", {
  headers: {
    Authorization: `Bearer ${token}`,
  },
});

const data = await res.json();
```

---

## 7. 📦 Intégration avec Kubernetes / Helm Chart

* Les valeurs d’environnement `.env.local` doivent être injectées dans le pod (via Helm `secret.yaml`).
* Le service peut être déployé derrière un Ingress NGINX ou Istio.
* Assurez-vous que l’image Docker construite avec `next build` et `next start` respecte les variables injectées.

---

## 📌 Résumé

| Élément                            | Fonction                           |
| ---------------------------------- | ---------------------------------- |
| `firebase-admin`                   | Vérifie les ID tokens côté serveur |
| `route.ts`                         | Protège un endpoint API Next.js 14 |
| `Authorization: Bearer <token>`    | Méthode d’envoi du token ID        |
| `.env.local` ou `secret.yaml`      | Stocke les credentials Firebase    |
| `ConfigMap` ou `Secret` Kubernetes | Injecte les credentials Firebase   |

---

Souhaitez-vous également un exemple pour **générer une image Docker** pour ce service Next.js et la **déployer via Helm** ?

