# Colinha da apresentação ao vivo — Kubernetes na Prática

> Mantenha este arquivo aberto no notebook durante a palestra. Todos os comandos
> assumem que você está com `source .env` carregado ou com os valores já no shell.

> **Sobre o ArgoCD:** a VM usada aqui (Always Free, shape Micro) tem só 1GB de RAM —
> pouco para rodar o ArgoCD completo de forma estável numa demo ao vivo. Por isso o
> "GitOps" da demo é feito por `scripts/gitops-poller.sh`, um systemd timer que faz
> `git pull` + `kubectl apply` a cada 20s — mesmo efeito prático (commit no Git muda o
> cluster sozinho), com uma fração do consumo de memória. O manifesto real do ArgoCD
> (`argocd/application.yaml`) fica no repositório como referência para quem for rodar
> isso num cluster maior. Pelo mesmo motivo, o Traefik (Ingress Controller) também vem
> desligado (`scripts/setup-vm.sh`) e a aplicação é exposta direto via Service
> NodePort na porta 80 — sem Ingress no meio do caminho.

## 0. Antes de começar (preparação, fora do horário da palestra)

```bash
# 1. Subir a VM, testar acesso
ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73

# 2. Instalar Docker + k3s (uma vez só, roda DENTRO da VM)
scp -i ssh-key-2026-10-23.key scripts/setup-vm.sh ubuntu@152.67.44.73:~/
ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73 "chmod +x setup-vm.sh && ./setup-vm.sh"

# 3. Apontar o DuckDNS para o IP da VM
source .env && ./scripts/duckdns-update.sh

# 4. Instalar o "GitOps leve" (clona o repo na VM + systemd timer)
scp -i ssh-key-2026-10-23.key scripts/install-gitops-poller.sh ubuntu@152.67.44.73:~/
ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73 "chmod +x install-gitops-poller.sh && ./install-gitops-poller.sh"

# 5. Build + import da primeira imagem direto no cluster (sem precisar de Docker Hub)
./scripts/vm-release.sh v1
git add -A && git commit -m "primeiro deploy" && git push
# em até 20s o gitops-poller aplica os manifests sozinho
```

No DuckDNS, cadastre o domínio `devfestinfoeste` (painel em https://www.duckdns.org) e confirme
que `devfestinfoeste.duckdns.org` resolve para `152.67.44.73`.

### Passos manuais obrigatórios (só você consegue fazer)

1. **Criar o subdomínio no DuckDNS**: entre em https://www.duckdns.org, faça login, no campo
   "sub domain" digite `devfestinfoeste` e clique em **add domain**. Sem isso o
   `duckdns-update.sh` retorna `KO` mesmo com o token certo.
2. **Liberar as portas 80 e 443 na OCI**: no console da Oracle Cloud, vá em
   *Networking → Virtual Cloud Networks → (sua VCN) → Security Lists* (ou *Network
   Security Groups*, se a VM usar um) e adicione duas *Ingress Rules*:
   - Source CIDR `0.0.0.0/0`, protocolo TCP, porta de destino `80`
   - Source CIDR `0.0.0.0/0`, protocolo TCP, porta de destino `443`

   Sem isso a plateia não consegue acessar o site de fora, mesmo com o DNS e o Ingress
   configurados certinho — o firewall da nuvem (Security List) é uma camada separada do
   firewall da própria VM.
3. **Dar o primeiro `git push`**: eu não tenho suas credenciais do GitHub neste ambiente,
   então rode uma vez, do seu notebook: `git push -u origin master`.

## 1. Durante a palestra — mostrando o cluster (demonstração ao vivo)

Abra um terminal com SSH já conectado na VM (`ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73`)
e use `alias k="sudo k3s kubectl"` para digitar menos.

```bash
alias k="sudo k3s kubectl"

# Ver os nós do cluster
k get nodes -o wide

# Ver o namespace criado
k get ns

# Ver os workloads
k get deployments -n infoeste26
k get replicasets -n infoeste26
k get pods -n infoeste26 -o wide
k get svc -n infoeste26   # repare no NodePort 80

# Ver detalhes de um pod (imagem, porta, labels)
k describe pod -n infoeste26 -l app=infoeste26-site

# Ver logs do site
k logs -n infoeste26 -l app=infoeste26-site --tail=20
```

Peça para a plateia acessar **http://devfestinfoeste.duckdns.org** pelo celular e notebook.

## 2. Escalonamento ao vivo

```bash
k get pods -n infoeste26 -w   # deixe rodando em outro terminal, mostrando em tempo real

# em outro terminal:
k scale deployment infoeste26-site -n infoeste26 --replicas=5
```

Mostre os pods novos subindo (`Pending` → `ContainerCreating` → `Running`) e explique que o
Service já distribui o tráfego entre todos eles automaticamente (load balancing interno).
Como a VM é pequena, não deixe mais que 4-5 réplicas de pé por muito tempo.

**Bônus didático:** espere ~20s e observe os pods voltando sozinhos pra 2 réplicas! O
`gitops-poller` reaplica `manifests/prd/deployment.yaml` (que diz `replicas: 2`) a cada
ciclo — é o mesmo comportamento de `selfHeal` do ArgoCD: mudança manual no cluster que
diverge do Git é desfeita automaticamente. Ótimo gancho para reforçar o conceito de GitOps.

Para escalar "de verdade" (sem o poller desfazer), mude `replicas` no
`manifests/prd/deployment.yaml`, commite e dê `git push`.

## 3. O momento "mágico": trocar a cor para todo mundo ver

No seu notebook (fora da VM, na raiz do repositório):

```bash
# 1. Troque a cor no CSS (app/public/styles.css, variável --accent)
#    ex: de #007c30 para #4285f4

# 2. Gere a nova imagem e importe direto no cluster (sem Docker Hub)
./scripts/vm-release.sh v2

# 3. Aponte o deployment pra nova tag
#    manifests/prd/deployment.yaml -> image: infoeste26-site:v2

# 4. Suba pro GitHub (branch master)
git add -A && git commit -m "muda cor para demo ao vivo"
git push
```

A partir daqui **não toque mais em nada no cluster**: o `gitops-poller.timer` (rodando na
VM) detecta o commit na branch `master` em até 20s e aplica sozinho. Peça para a plateia
dar F5 na página — a cor muda para todo mundo ao mesmo tempo.

Se quiser mostrar o poller sincronizando em tempo real (opcional):

```bash
ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73
sudo journalctl -u gitops-poller.service -f
```

## 4. Comandos de apoio para dúvidas da plateia

```bash
k get pods -n infoeste26 --show-labels      # mostrar labels/selectors
k explain deployment.spec                    # explorar campos de um recurso
k get events -n infoeste26 --sort-by=.lastTimestamp   # debug rápido
k version                                    # versão do cliente/servidor
systemctl list-timers gitops-poller.timer    # ver quando o poller roda de novo
```

## 5. Se algo der errado (plano de contingência)

- Imagem não builda/importa a tempo → já ter a `v2` importada previamente e seguir só com o
  `kubectl set image` manual para simular o efeito:
  ```bash
  k set image deployment/infoeste26-site site=infoeste26-site:v2 -n infoeste26
  ```
- Internet do auditório instável → ter prints/gravação de tela de um teste prévio do fluxo
  completo como backup.
- DuckDNS não resolve na hora → mostrar direto pelo IP com `curl http://152.67.44.73` e
  explicar que normalmente seria o domínio.
- VM lenta/travando durante a demo → evite rodar `vm-release.sh` e escalonar ao mesmo
  tempo; a VM tem só 1GB de RAM + 2GB de swap, prefira fazer uma coisa de cada vez.
