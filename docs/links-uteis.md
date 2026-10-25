# Links e exemplos prontos para usar ao vivo

## Docker (antes de entrar em Kubernetes)

Exemplo simples para rodar na hora, sem precisar de projeto nenhum:

```bash
# o mais simples de todos, só pra provar que o Docker funciona
docker run hello-world

# um "app" de verdade rodando em segundos
docker run -d --name nginx-demo -p 8080:80 nginx
# abrir http://localhost:8080 no navegador
docker ps
docker stop nginx-demo && docker rm nginx-demo
```

Mensagem-chave: "a mesma imagem roda igual no seu notebook, no servidor do colega e na nuvem" —
isso é o problema que o Kubernetes resolve em escala (muitos containers, muitas máquinas).

## kubernetes.io — conteúdo oficial para usar durante a aula

| O que é | Link | Uso sugerido |
|---|---|---|
| Tutorial interativo com terminal no navegador (não precisa instalar nada) | https://kubernetes.io/docs/tutorials/kubernetes-basics/ | Deixar projetado e deixar a plateia seguir no celular/notebook em paralelo |
| Conceito de Pods | https://kubernetes.io/docs/concepts/workloads/pods/ | Base para explicar node/pod/container |
| Conceito de Deployments (com YAML de exemplo oficial) | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ | Copiar o YAML de exemplo da seção "Creating a Deployment" e explicar campo a campo |
| ReplicaSet | https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ | Mostrar a relação Deployment → ReplicaSet → Pods |
| StatefulSet | https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/ | Contraste rápido: quando usar em vez de Deployment (bancos de dados, identidade estável) |
| DaemonSet | https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/ | Exemplo: agente de monitoramento/log em todo nó |
| Services | https://kubernetes.io/docs/concepts/services-networking/service/ | YAML de exemplo oficial do Service |
| Ingress | https://kubernetes.io/docs/concepts/services-networking/ingress/ | YAML de exemplo oficial do Ingress |
| Namespaces | https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/ | Comando `kubectl get namespaces` |
| Visão geral da arquitetura (control plane x nodes) | https://kubernetes.io/docs/concepts/architecture/ | Diagrama oficial para a parte teórica |
| kubectl Cheat Sheet | https://kubernetes.io/docs/reference/kubectl/cheatsheet/ | Deixar aberto como referência rápida de comandos |
| Instalar o kubectl | https://kubernetes.io/docs/tasks/tools/ | Para quem quiser seguir junto depois da aula |
| Minikube (cluster local para treinar depois) | https://minikube.sigs.k8s.io/docs/start/ | Indicar como "próximo passo" pra quem não tem VM na nuvem |
| k3s (o que usamos na VM da OCI) | https://docs.k3s.io/ | Explicar por que escolhemos ele: leve, 1 binário, já vem com Ingress |
| ArgoCD — Getting Started | https://argo-cd.readthedocs.io/en/stable/getting_started/ | Base do que rodamos no `scripts/setup-vm.sh` |
| O que é GitOps | https://opengitops.dev/ | Definição oficial dos 4 princípios de GitOps |

## Oracle Cloud (Always Free)

- Tier gratuito: https://www.oracle.com/cloud/free/
- Documentação de Compute (VMs): https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm

## DuckDNS

- Site: https://www.duckdns.org
- Como funciona (dynamic DNS grátis apontando um subdomínio `*.duckdns.org` para o IP da sua máquina/VM)
