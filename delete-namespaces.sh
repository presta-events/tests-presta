#!/bin/bash

# Fichier de log
LOGFILE="deleted_namespaces_$(date +%Y%m%d_%H%M%S).log"

# Namespaces à exclure pour éviter une catastrophe
EXCLUDE=("kube-system" "kube-public" "kube-node-lease" "default")

# Lister les namespaces candidats à la suppression
echo "🔍 Recherche des namespaces se terminant par 'namespace'..."
NAMESPACES=$(kubectl get ns --no-headers | awk '{print $1}' | grep 'namespace$')

# Appliquer l'exclusion
for ns in "${EXCLUDE[@]}"; do
  NAMESPACES=$(echo "$NAMESPACES" | grep -v "^$ns$")
done

# Si aucun namespace trouvé
if [[ -z "$NAMESPACES" ]]; then
  echo "✅ Aucun namespace à supprimer."
  exit 0
fi

# Afficher la liste
echo "📋 Les namespaces suivants vont être supprimés :"
echo "$NAMESPACES"
echo

# Demander confirmation
read -p "❗ Confirmer la suppression de ces namespaces ? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "❌ Suppression annulée."
  exit 1
fi

# Suppression
echo "🗑️  Suppression des namespaces en cours..."
for ns in $NAMESPACES; do
  echo "➡️  Suppression de $ns..."
  kubectl delete ns "$ns" | tee -a "$LOGFILE"
done

echo
echo "✅ Suppression terminée. Journal dans : $LOGFILE"
