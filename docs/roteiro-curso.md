# Roteiro do curso — Kubernetes na Prática: Deploy Real em Ambiente Produtivo

**Data:** 28/10/2026 · **Horário:** 19h às 22h30 (3h30) · **Local:** Auditório da FIPP

> Este roteiro serve de base para o slide deck (`.pptx`) e guia o tempo de fala. Ajuste
> os minutos conforme o ritmo real da turma — o bloco de demonstração ao vivo (seção 9)
> é o coração da aula e não deve ser cortado.

## 1. Abertura e DevOps (19h00 – 19h15 · 15min)

- Boas-vindas, GDG Presidente Prudente, 4º DevFest, INFOESTE 2026, instrutores.
- Gancho: "eu sou DevOps — o que isso quer dizer na prática?"
- O que é DevOps: cultura que une desenvolvimento (Dev) e operação (Ops), automação,
  entrega contínua, responsabilidade compartilhada pelo que vai pra produção.
- Por que isso importa para a palestra: Kubernetes é uma das ferramentas centrais do
  "Ops" moderno — ele é o motivo de existirem vagas e práticas de DevOps como conhecemos hoje.

## 2. Como era o deploy antigamente (19h15 – 19h25 · 10min)

- Era dos servidores físicos: comprar/alugar uma máquina, instalar o sistema operacional,
  configurar manualmente, instalar dependências, subir a aplicação "na unha".
- Problemas: demorado, caro, difícil de escalar, "funciona na minha máquina", um
  servidor por aplicação (desperdício de recursos), falha de hardware derruba tudo.
- Ainda existe? Sim — bancos, governo e sistemas legados ainda rodam em servidores
  físicos dedicados (bare metal) por motivos de compliance, performance ou legado técnico.

## 3. Máquinas Virtuais (19h25 – 19h40 · 15min)

- O que é: um hypervisor (VMware, KVM, Hyper-V) permite rodar vários "computadores
  virtuais" isolados dentro de um servidor físico, cada um com seu próprio SO completo.
- Ganho: melhor uso do hardware, isolamento entre aplicações, mais fácil de provisionar
  que um servidor físico novo.
- Limitação que continua: cada VM carrega um SO inteiro (pesado, lento para subir,
  consome muita memória/disco só para existir).

## 4. Containers e Docker (19h40 – 20h00 · 20min)

- O que é um container: processo isolado que compartilha o kernel do SO hospedeiro,
  mas empacota só o que a aplicação precisa (bibliotecas, dependências) — muito mais
  leve e rápido que uma VM.
- Imagem x Container: a **imagem** é o "molde" (read-only); o **container** é a
  instância rodando daquela imagem.
- **Demonstração ao vivo (Docker):**
  ```bash
  docker run hello-world
  docker run -d --name nginx-demo -p 8080:80 nginx
  # abrir http://localhost:8080
  docker ps
  docker stop nginx-demo && docker rm nginx-demo
  ```
- Gancho para Kubernetes: "e se eu precisar rodar 50 containers, em várias máquinas,
  substituir automaticamente os que caem, e distribuir tráfego entre eles?" → ninguém
  faz isso na mão. É aí que entra o Kubernetes.

## 5. O que é Kubernetes (20h00 – 20h15 · 15min)

- Orquestrador de containers: automatiza deploy, escalonamento e operação de aplicações
  em containers.
- Por que virou padrão de mercado: nasceu do Borg (Google), hoje é mantido pela CNCF,
  roda igual em qualquer nuvem (AWS, Azure, GCP, Oracle Cloud) ou on-premises —
  portabilidade é o grande diferencial.
- O que ele resolve: auto-healing (reinicia o que cai), escalonamento automático,
  load balancing, rollout/rollback de versões, service discovery.

### Intervalo sugerido (20h15 – 20h30 · 15min)

## 6. Arquitetura por dentro (20h30 – 21h00 · 30min)

- **Node:** uma máquina (VM ou servidor físico) que faz parte do cluster e roda os Pods.
- **Cluster:** o conjunto de nós trabalhando juntos como uma unidade só.
- **Control Plane x Worker Nodes:** quem decide (API Server, Scheduler, Controller
  Manager, etcd) x quem executa (kubelet, kube-proxy, container runtime).
- **Pod:** a menor unidade do Kubernetes — um ou mais containers que compartilham rede
  e armazenamento.
- **Imagem:** o pacote da aplicação (ex: `nginx:1.27`), geralmente vindo de um registry
  (Docker Hub, GHCR).
- **Porta (port/targetPort):** a porta que o container expõe x a porta que o Service
  expõe — são conceitos separados de propósito.
- **Namespace:** uma forma de dividir o cluster logicamente (ex: `infoeste26`, `argocd`,
  `kube-system`) — útil para organizar times/ambientes no mesmo cluster.
- **Workloads (controladores que gerenciam Pods):**
  - **ReplicaSet:** garante que sempre existam N réplicas de um Pod rodando.
  - **Deployment:** gerencia ReplicaSets para você, permitindo atualizações
    (rolling update) e rollback — é o que vamos usar na demo.
  - **StatefulSet:** para aplicações com estado (ex: banco de dados) — cada Pod tem
    identidade e armazenamento estáveis.
  - **DaemonSet:** garante que um Pod rode em **todo** nó do cluster (ex: agente de
    monitoramento, coletor de logs).
- **Versões:** Kubernetes lança uma nova versão minor a cada ~4 meses (ex: 1.29, 1.30,
  1.31...); cada versão tem suporte por tempo limitado — importante manter o cluster
  atualizado por segurança.

## 7. Arquivo YAML (21h00 – 21h15 · 15min)

- Por que YAML: é como "descrevemos" para o Kubernetes o que queremos que exista
  (declarativo) — você diz o estado desejado, o Kubernetes cuida de alcançá-lo.
- Elementos obrigatórios de um manifesto:
  - `apiVersion` — qual versão da API daquele recurso.
  - `kind` — o tipo de recurso (Deployment, Service, Pod, Ingress...).
  - `metadata` — nome, namespace, labels.
  - `spec` — a especificação do que você quer (réplicas, imagem, portas...).
- Mostrar ao vivo o `manifests/prd/deployment.yaml` deste repositório, campo a campo.
- O que precisa estar instalado para rodar tudo isso:
  - Um cluster Kubernetes (local: minikube/kind; produção: k3s, EKS, GKE, AKS, OKE...).
  - `kubectl` (cliente de linha de comando que fala com a API do cluster).
  - Um container runtime no nó (containerd, no caso do k3s).
  - Opcional, mas recomendado em produção: um Ingress Controller (Traefik, NGINX) e,
    para GitOps, o ArgoCD.

## 8. GitOps, Ingress e DuckDNS (21h15 – 21h40 · 25min)

- **O que é GitOps:** o Git vira a "fonte da verdade" do que deveria estar rodando no
  cluster. Em vez de aplicar comandos manualmente, você só edita arquivos e dá `git
  push` — uma ferramenta (ArgoCD) garante que o cluster fica igual ao repositório.
- **ArgoCD na prática:** fica dentro do cluster observando um repositório/branch (no
  nosso caso, `master`, pasta `manifests/prd`). Toda mudança commitada é detectada e
  sincronizada automaticamente (`syncPolicy.automated` com `selfHeal`). Mostre o
  manifesto `argocd/application.yaml` do repositório como referência.
- Nota transparente para a plateia: na VM gratuita usada na demo (1GB de RAM) o ArgoCD
  completo não cabe de forma estável, então quem está rodando ao vivo é um "GitOps
  caseiro" (`scripts/gitops-poller.sh`, um systemd timer com `git pull` + `kubectl
  apply` a cada 20s) — mesmo conceito, versão enxuta. Ótimo gancho para falar sobre
  dimensionamento de recursos em produção.
- Mostrar o diagrama do fluxo GitOps (README.md do repositório).
- **Ingress:** a porta de entrada HTTP/HTTPS do cluster — mapeia um domínio (host) para
  um Service interno. No k3s usamos o **Traefik**, que já vem instalado por padrão.
- **DuckDNS:** serviço gratuito de DNS dinâmico — cadastra um subdomínio
  (`devfestinfoeste.duckdns.org`) que aponta para o IP público da nossa VM, sem precisar
  comprar um domínio próprio. Como é "dinâmico", se o IP da VM mudar, basta rodar o
  script de update novamente.
- Mostrar o diagrama do fluxo de rede (README.md): Browser → DuckDNS → IP público →
  Traefik (Ingress) → Service → Pods.

## 9. Demonstração ao vivo (21h40 – 22h10 · 30min)

Seguir à risca o [`docs/colinha-apresentacao.md`](colinha-apresentacao.md):

1. Mostrar o cluster já rodando na OCI (`kubectl get nodes/pods/svc/ingress`).
2. Pedir para a plateia acessar `http://devfestinfoeste.duckdns.org` pelo celular/notebook.
3. Escalonar o Deployment ao vivo (`kubectl scale ... --replicas=5`) e mostrar os Pods
   subindo em tempo real.
4. O momento "mágico": trocar uma cor no código, gerar uma nova imagem (build + import
   direto no cluster, via `scripts/vm-release.sh`), atualizar o manifesto e dar
   `git push` — o `gitops-poller` sincroniza sozinho em até 20s e a cor muda para todo
   mundo que estiver com a página aberta.

## 10. Kahoot e encerramento (22h10 – 22h30 · 20min)

- Jogar o Kahoot com perguntas fáceis (ver [`docs/kahoot-perguntas.md`](kahoot-perguntas.md)).
- Premiar os 3 primeiros colocados (brinde simbólico, se houver).
- Encerramento: recapitular a jornada (servidor físico → VM → container → Kubernetes →
  GitOps), divulgar o repositório com todo o material e redes do GDG Presidente Prudente.
- Agradecimentos e perguntas da plateia.
