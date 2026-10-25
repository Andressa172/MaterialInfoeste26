# Kubernetes na Prática: Deploy Real em Ambiente Produtivo

Material de apoio da palestra **Kubernetes na Prática: Deploy Real em Ambiente Produtivo**,
apresentada no **4º DevFest Presidente Prudente (GDG Presidente Prudente)** durante a
**38ª Semana de Computação e Informática da FIPP/UNOESTE (INFOESTE 2026)**.

- **Local:** Auditório da FIPP (Presencial)
- **Data/Horário:** 28/10/2026, das 19h às 22h30
- **Instrutores:** Andressa Felisberto Ferreira Diniz e Felipe Meneghetti Barreto

## O que tem aqui

| Pasta | Conteúdo |
|---|---|
| [`app/`](app) | Site de demonstração (HTML/CSS responsivo) usado ao vivo na palestra |
| [`manifests/prd/`](manifests/prd) | Manifestos Kubernetes (Namespace, Deployment, Service, Ingress) |
| [`argocd/`](argocd) | `Application` do ArgoCD (referência) — na demo, o GitOps real é feito pelo `gitops-poller` |
| [`scripts/`](scripts) | Scripts para instalar o cluster, o GitOps leve, atualizar o DuckDNS e publicar novas imagens |
| [`docs/`](docs) | Roteiro do curso, colinha de comandos ao vivo, links úteis e perguntas do Kahoot |

## Arquitetura da demo

```
Plateia (celular/notebook)
        │  http://devfestinfoeste.duckdns.org
        ▼
     DuckDNS  ──resolve para──▶  IP público da VM (OCI Always Free)
        │
        ▼
  Traefik (Ingress Controller do k3s, portas 80/443 do nó)
        │
        ▼
  Service infoeste26-site  ──►  Pods (ReplicaSet gerenciado pelo Deployment)
```

### Fluxo GitOps

```
Dev edita manifests/prd/*.yaml (ex: nova tag de imagem)
        │
        ▼
   git push na branch master  ──►  GitHub (este repositório)
        │
        ▼
  Algo dentro do cluster observa o repositório/branch
        │
        ▼
  Detecta divergência e aplica (sync) os manifestos no cluster automaticamente
```

Em um cluster com recursos de sobra, esse "algo" é o **ArgoCD** (`argocd/application.yaml`).
Na VM Always Free usada nesta demo (1GB de RAM), o ArgoCD completo não roda de forma
estável, então quem cumpre esse papel é o `scripts/gitops-poller.sh`: um systemd timer
que faz `git pull` + `kubectl apply` a cada 20s — mesmo conceito de GitOps, pegada leve.

## Como reproduzir em casa

1. Suba uma VM gratuita (Oracle Cloud Always Free, por exemplo — prefira um shape com
   pelo menos 2-4GB de RAM se quiser rodar o ArgoCD completo).
2. Rode `scripts/setup-vm.sh` dentro da VM para instalar Docker + k3s.
3. Crie uma conta gratuita no [DuckDNS](https://www.duckdns.org) e aponte um subdomínio para o IP da VM (`scripts/duckdns-update.sh`).
4. Gere e importe sua imagem direto no cluster com `scripts/vm-release.sh` (não precisa de Docker Hub).
5. Para GitOps automático, escolha um caminho:
   - VM com recursos de sobra: ajuste `argocd/application.yaml` com seus dados e aplique no cluster.
   - VM pequena (como a desta demo): rode `scripts/install-gitops-poller.sh` dentro dela.

Veja o passo a passo completo em [`docs/colinha-apresentacao.md`](docs/colinha-apresentacao.md).

## Outros materiais

- [Apresentação (.pptx)](docs/apresentacao/kubernetes-na-pratica-infoeste26.pptx)
- [Roteiro do curso](docs/roteiro-curso.md)
- [Links e exemplos prontos do kubernetes.io](docs/links-uteis.md)
- [Perguntas do Kahoot](docs/kahoot-perguntas.md) ([CSV para importar](docs/kahoot-perguntas.csv))
