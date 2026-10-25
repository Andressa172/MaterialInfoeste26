#!/usr/bin/env bash
# Builda a imagem do site DENTRO da VM (a partir do clone do repo que já
# está lá) e importa direto no containerd do k3s — sem precisar de Docker
# Hub/GHCR. Roda no seu notebook, a partir da raiz do repositório.
#
# Uso: ./scripts/vm-release.sh v2
set -euo pipefail
TAG="${1:?uso: ./scripts/vm-release.sh <tag> (ex: v2)}"
source .env 2>/dev/null || true
: "${VM_IP:?defina VM_IP no .env}"
SSH_KEY="${SSH_KEY:-../ssh-key-2026-10-23.key}"
IMAGE="infoeste26-site:${TAG}"
REPO_DIR="MaterialInfoeste26"

echo "==> Build + import da imagem ${IMAGE} na VM (puxando a última versão do app/ primeiro)"
ssh -i "$SSH_KEY" "ubuntu@${VM_IP}" "
  set -e
  cd ~/${REPO_DIR}
  git pull --quiet
  cd app
  sudo docker build -t ${IMAGE} .
  sudo docker save ${IMAGE} | sudo k3s ctr images import -
"

echo
echo "Imagem ${IMAGE} pronta no cluster."
echo "Agora edite manifests/prd/deployment.yaml -> image: ${IMAGE}"
echo "e faça: git add -A && git commit -m 'deploy: imagem ${TAG}' && git push"
echo "O gitops-poller.timer (rodando na VM) detecta o commit em até 20s e aplica sozinho."
