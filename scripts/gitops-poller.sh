#!/usr/bin/env bash
# "GitOps" leve: a cada execução, puxa a branch master do GitHub e aplica
# manifests/prd no cluster. Substitui o ArgoCD quando o cluster é pequeno
# demais pra rodar o controller completo (ver docs/colinha-apresentacao.md).
# Roda DENTRO da VM via systemd timer (scripts/install-gitops-poller.sh).
set -euo pipefail
REPO_DIR="$HOME/MaterialInfoeste26"

cd "$REPO_DIR"
git fetch origin master --quiet
if ! git diff --quiet HEAD "origin/master" -- manifests/prd; then
  echo "$(date -Is) mudança detectada em manifests/prd, sincronizando..."
fi
git reset --hard origin/master --quiet
sudo k3s kubectl apply -f manifests/prd/
