#!/usr/bin/env bash
# Roda DENTRO da VM Ubuntu da OCI. Instala Docker (pra buildar a imagem do
# site) e o k3s, já configurado pro perfil de recursos de uma VM Always
# Free pequena (1GB de RAM):
#   - Traefik (Ingress Controller) desligado: não cabe de forma estável
#     nessa VM; a aplicação é exposta direto via Service NodePort.
#   - Range de NodePort ampliado pra incluir a porta 80 (o padrão do
#     Kubernetes é 30000-32767).
# Depois deste script, rode scripts/install-gitops-poller.sh pra ligar o
# "GitOps leve" que mantém o cluster sincronizado com este repositório.
set -euo pipefail

echo "==> Instalando Docker..."
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$(whoami)"
fi

echo "==> Configurando k3s (Traefik desligado, NodePort 80 liberado)..."
sudo mkdir -p /etc/rancher/k3s
printf 'disable:\n  - traefik\nkube-apiserver-arg:\n  - service-node-port-range=80-32767\n' \
  | sudo tee /etc/rancher/k3s/config.yaml > /dev/null

echo "==> Instalando k3s..."
curl -sfL https://get.k3s.io | sh -

echo "==> Aguardando node ficar Ready..."
sudo k3s kubectl wait --for=condition=Ready node --all --timeout=180s

echo
echo "k3s instalado. kubeconfig em: /etc/rancher/k3s/k3s.yaml"
echo "Para usar sem sudo: sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown \$(id -u):\$(id -g) ~/.kube/config"
echo
echo "Próximo passo: rode scripts/install-gitops-poller.sh pra clonar o repositório"
echo "e ligar o GitOps leve (git pull + kubectl apply a cada 20s)."
