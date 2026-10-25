#!/usr/bin/env bash
# Atualiza o registro A do DuckDNS para apontar para o IP público da VM.
# Uso: source .env && ./scripts/duckdns-update.sh
set -euo pipefail
: "${DUCKDNS_DOMAIN:?defina DUCKDNS_DOMAIN}"
: "${DUCKDNS_TOKEN:?defina DUCKDNS_TOKEN}"
: "${VM_IP:?defina VM_IP}"

curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&ip=${VM_IP}"
echo
echo "Domínio: ${DUCKDNS_DOMAIN}.duckdns.org -> ${VM_IP}"
