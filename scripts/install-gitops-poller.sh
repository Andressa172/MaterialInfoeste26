#!/usr/bin/env bash
# Roda DENTRO da VM. Clona o repositório e instala um systemd timer que
# chama gitops-poller.sh a cada 20s — nosso "GitOps" leve, no lugar do
# ArgoCD completo (que não cabe numa VM de 1GB de RAM). Ver
# docs/colinha-apresentacao.md para o porquê dessa escolha.
set -euo pipefail
REPO_URL="https://github.com/Andressa172/MaterialInfoeste26.git"
REPO_DIR="$HOME/MaterialInfoeste26"

if [ ! -d "$REPO_DIR" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
fi
chmod +x "$REPO_DIR/scripts/gitops-poller.sh"

sudo tee /etc/systemd/system/gitops-poller.service > /dev/null <<EOF
[Unit]
Description=GitOps poller (git pull + kubectl apply) para a demo INFOESTE 2026
After=k3s.service

[Service]
Type=oneshot
User=$(whoami)
WorkingDirectory=$REPO_DIR
ExecStart=$REPO_DIR/scripts/gitops-poller.sh
EOF

sudo tee /etc/systemd/system/gitops-poller.timer > /dev/null <<EOF
[Unit]
Description=Roda o gitops-poller a cada 20s

[Timer]
OnBootSec=10s
OnUnitActiveSec=20s
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now gitops-poller.timer

echo
echo "Poller instalado. Para acompanhar ao vivo:"
echo "  sudo journalctl -u gitops-poller.service -f"
echo "Para checar o timer:"
echo "  systemctl list-timers gitops-poller.timer"
