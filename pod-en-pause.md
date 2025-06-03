En Kubernetes, il n'existe pas de commande directe pour "mettre en pause" un pod individuel qui est en status Running. Toutefois, selon le contexte (pod autonome, géré par un Deployment, Job, etc.), voici plusieurs solutions réalistes pour le "mettre en pause" :

---

## 🧭 Cas 1 : Pod autonome (ex : lancé avec kubectl run)

🎯 Si le pod n'est pas contrôlé par un controller (Deployment, ReplicaSet...), tu peux le "stopper" simplement :

```bash
kubectl delete pod <pod-name>
```

➡️ Cela arrête complètement le pod.

Tu peux ensuite le relancer plus tard avec la même commande ou depuis un manifeste YAML.

---

## 🧭 Cas 2 : Pod géré par un Deployment ou ReplicaSet

Ces ressources vont automatiquement redémarrer les pods supprimés. Pour "mettre en pause" :

✅ Réduis le nombre de replicas à 0 :

```bash
kubectl scale deployment <deployment-name> --replicas=0
```

Cela supprime tous les pods liés, donc "pause" effective.

Et pour le redémarrer plus tard :

```bash
kubectl scale deployment <deployment-name> --replicas=1
```

---

## 🧭 Cas 3 : Pod en cours d’exécution mais tu veux "le geler" sans le tuer

Il n’y a pas de commande native pour « suspendre » un conteneur, mais voici deux approches techniques :

### 1. Utiliser `kubectl exec` pour suspendre le processus

Si le pod contient un conteneur avec un shell (comme alpine, bash…), tu peux suspendre son exécution :

```bash
kubectl exec -it <pod-name> -- kill -STOP 1
```

* Cela envoie un signal `SIGSTOP` au processus PID 1 du conteneur, le mettant en pause.
* Pour le relancer ensuite :

```bash
kubectl exec -it <pod-name> -- kill -CONT 1
```

⚠️ Cela ne fonctionne que si l’image contient `kill`, et que le PID 1 peut recevoir ce signal.

---

## 🧭 Cas 4 : Utiliser `kubectl cordon` ou `drain` pour arrêter un nœud (option avancée)

Si ton but est de stopper les pods indirectement en désactivant leur nœud (cluster-level pause) :

```bash
kubectl cordon <node-name>         # Empêche les pods d’être programmés dessus
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

---

## 🧪 Bonus : Simuler une pause avec `sleep` ou `read`

Redémarre le pod avec une commande qui le garde vivant mais inactif :

```bash
kubectl run paused-pod --image=alpine -- sleep 3600
```

---

Souhaites-tu que je te génère un manifest YAML pour un pod "gelé" ou simulé inactif ?

