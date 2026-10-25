#!/usr/bin/env bash
# Builda a imagem do site e publica no Docker Hub.
# Uso: ./scripts/build-and-push.sh v2
set -euo pipefail
TAG="${1:?uso: ./scripts/build-and-push.sh <tag> (ex: v2)}"
source .env 2>/dev/null || true
: "${DOCKERHUB_USER:?defina DOCKERHUB_USER no .env}"

IMAGE="${DOCKERHUB_USER}/infoeste26-site:${TAG}"

echo "==> Build ${IMAGE}"
docker build -t "${IMAGE}" ./app

echo "==> Push ${IMAGE}"
docker push "${IMAGE}"

echo
echo "Agora edite manifests/prd/deployment.yaml trocando a tag da imagem para ${TAG}"
echo "e faça: git add -A && git commit -m 'deploy: imagem ${TAG}' && git push"
echo "O ArgoCD detecta o commit na branch master e sincroniza sozinho."
