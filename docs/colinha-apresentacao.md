# Colinha da apresentação ao vivo — Kubernetes na Prática

> Mantenha este arquivo aberto no notebook durante a palestra. Todos os comandos
> assumem que você está com `source .env` carregado ou com os valores já no shell.

## 0. Antes de começar (preparação, fora do horário da palestra)

```bash
# 1. Subir a VM, testar acesso
ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73

# 2. Instalar k3s + ArgoCD (uma vez só, roda DENTRO da VM)
scp -i ssh-key-2026-10-23.key scripts/setup-vm.sh ubuntu@152.67.44.73:~/
ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73 "chmod +x setup-vm.sh && ./setup-vm.sh"

# 3. Apontar o DuckDNS para o IP da VM
source .env && ./scripts/duckdns-update.sh

# 4. Build e push da imagem v1, ajustar deployment.yaml e dar o primeiro apply manual
./scripts/build-and-push.sh v1
# edite manifests/prd/deployment.yaml -> image: SEU_USUARIO/infoeste26-site:v1
git add -A && git commit -m "primeiro deploy" && git push

# 5. Criar a Application do ArgoCD (uma vez só)
scp -i ssh-key-2026-10-23.key argocd/application.yaml ubuntu@152.67.44.73:~/
ssh -i ssh-key-2026-10-23.key ubuntu@152.67.44.73 "sudo k3s kubectl apply -f application.yaml"
```

No DuckDNS, cadastre o domínio `devfestinfoeste` (painel em https://www.duckdns.org) e confirme
que `devfestinfoeste.duckdns.org` resolve para `152.67.44.73`.

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
k get svc -n infoeste26
k get ingress -n infoeste26

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

Para voltar: `k scale deployment infoeste26-site -n infoeste26 --replicas=2`

## 3. O momento "mágico": trocar a cor para todo mundo ver

No seu notebook (fora da VM, na raiz do repositório):

```bash
# 1. Troque a cor no CSS (app/public/styles.css, variável --accent)
#    ex: de #007c30 para #4285f4

# 2. Gere uma nova imagem e publique
./scripts/build-and-push.sh v2

# 3. Aponte o deployment pra nova tag
#    manifests/prd/deployment.yaml -> image: SEU_USUARIO/infoeste26-site:v2

# 4. Suba pro GitHub (branch master)
git add -A && git commit -m "muda cor para demo ao vivo"
git push
```

A partir daqui **não toque mais em nada no cluster**: o ArgoCD detecta o commit na branch
`master`, vê que o manifesto mudou, e sincroniza sozinho. Peça para a plateia dar F5 na
página — a cor muda para todo mundo ao mesmo tempo.

Se quiser mostrar o ArgoCD sincronizando em tempo real (opcional, via port-forward):

```bash
ssh -i ssh-key-2026-10-23.key -L 8080:localhost:8080 ubuntu@152.67.44.73
# dentro da VM:
sudo k3s kubectl -n argocd port-forward svc/argocd-server 8080:443 --address 0.0.0.0
# abra https://localhost:8080 (usuário admin, senha do comando abaixo)
sudo k3s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## 4. Comandos de apoio para dúvidas da plateia

```bash
k get pods -n infoeste26 --show-labels      # mostrar labels/selectors
k explain deployment.spec                    # explorar campos de um recurso
k get events -n infoeste26 --sort-by=.lastTimestamp   # debug rápido
k version                                    # versão do cliente/servidor
```

## 5. Se algo der errado (plano B)

- Imagem não builda/push falha → já ter a `v1` publicada previamente e seguir só com o
  `kubectl set image` manual para simular o efeito:
  ```bash
  k set image deployment/infoeste26-site site=SEU_USUARIO/infoeste26-site:v2 -n infoeste26
  ```
- Internet do auditório instável → ter prints/gravação de tela de um teste prévio do fluxo
  completo como backup.
- DuckDNS não resolve na hora → mostrar direto pelo IP com `curl http://152.67.44.73` e
  explicar que normalmente seria o domínio.
