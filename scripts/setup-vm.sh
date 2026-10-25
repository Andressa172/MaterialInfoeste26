#!/usr/bin/env bash
# Roda DENTRO da VM Ubuntu da OCI. Instala Docker (pra buildar a imagem do
# site), k3s (Kubernetes leve, já vem com Traefik como Ingress Controller)
# e o ArgoCD.
set -euo pipefail

echo "==> Instalando Docker..."
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$(whoami)"
fi

echo "==> Instalando k3s..."
curl -sfL https://get.k3s.io | sh -

echo "==> Aguardando node ficar Ready..."
sudo k3s kubectl wait --for=condition=Ready node --all --timeout=120s

echo "==> Criando namespace do argocd..."
sudo k3s kubectl create namespace argocd --dry-run=client -o yaml | sudo k3s kubectl apply -f -

echo "==> Instalando ArgoCD..."
sudo k3s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "==> Aguardando pods do ArgoCD..."
sudo k3s kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s || true

echo
echo "k3s instalado. kubeconfig em: /etc/rancher/k3s/k3s.yaml"
echo "Para usar sem sudo: sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown \$(id -u):\$(id -g) ~/.kube/config"
echo
echo "Senha inicial do ArgoCD (admin):"
echo "  sudo k3s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
echo
echo "Para acessar a UI do ArgoCD (opcional, via port-forward):"
echo "  sudo k3s kubectl -n argocd port-forward svc/argocd-server 8080:443 --address 0.0.0.0"
