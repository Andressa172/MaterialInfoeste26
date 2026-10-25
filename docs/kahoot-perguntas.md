# Perguntas do Kahoot — Kubernetes na Prática

Nível: **fácil**, só para descontrair ao final da palestra (22h10–22h30). Todas as
respostas foram ditas em algum momento da aula — o objetivo é fixar, não pegar ninguém.
Sugestão: 20 segundos por pergunta, 4 alternativas.

> Para montar no site kahoot.com: Create → Kahoot → cole as perguntas manualmente, ou
> importe via planilha (modelo em `docs/kahoot-perguntas.csv`).

1. **O que significa "k8s"?**
   - A) Kubernetes (há 8 letras entre o K e o S) ✅
   - B) Kernel 8 Sistemas
   - C) Key 8 Service
   - D) Kit de 8 Servidores

2. **Qual empresa criou o Kubernetes originalmente?**
   - A) Amazon
   - B) Microsoft
   - C) Google ✅
   - D) Oracle

3. **Qual é a menor unidade que o Kubernetes gerencia?**
   - A) Node
   - B) Pod ✅
   - C) Container
   - D) Cluster

4. **Um conjunto de nós trabalhando juntos é chamado de:**
   - A) Namespace
   - B) Deployment
   - C) Cluster ✅
   - D) Pipeline

5. **Qual ferramenta usamos para rodar containers antes de falar de Kubernetes?**
   - A) Docker ✅
   - B) Postman
   - C) Figma
   - D) Jenkins

6. **Qual workload do Kubernetes é ideal para bancos de dados (aplicações com estado)?**
   - A) DaemonSet
   - B) StatefulSet ✅
   - C) CronJob
   - D) ConfigMap

7. **Qual workload garante que um Pod rode em TODO nó do cluster?**
   - A) DaemonSet ✅
   - B) ReplicaSet
   - C) Deployment
   - D) Job

8. **Em que formato escrevemos os manifestos do Kubernetes?**
   - A) JSON apenas
   - B) XML
   - C) YAML ✅
   - D) INI

9. **Qual campo do YAML diz qual TIPO de recurso estamos criando (Deployment, Service...)?**
   - A) spec
   - B) metadata
   - C) kind ✅
   - D) apiVersion

10. **O que é o ArgoCD, no contexto desta palestra?**
    - A) Um banco de dados
    - B) Uma ferramenta de GitOps que sincroniza o cluster com o Git ✅
    - C) Um editor de código
    - D) Um sistema operacional

11. **Qual serviço usamos hoje para ter um domínio gratuito apontando para a VM?**
    - A) GoDaddy
    - B) DuckDNS ✅
    - C) Registro.br
    - D) Cloudflare Pro

12. **Qual comando usamos para colocar mais réplicas da nossa aplicação rodando?**
    - A) kubectl scale ✅
    - B) kubectl delete
    - C) kubectl stop
    - D) kubectl build

13. **Em qual nuvem subimos o cluster da demonstração de hoje?**
    - A) AWS
    - B) Azure
    - C) Oracle Cloud (OCI) ✅
    - D) IBM Cloud

14. **No fluxo de GitOps mostrado hoje, qual branch o ArgoCD está observando?**
    - A) main
    - B) develop
    - C) master ✅
    - D) release

15. **O componente do k3s responsável por rotear o tráfego HTTP até o Service é o:**
    - A) kubelet
    - B) Traefik (Ingress) ✅
    - C) etcd
    - D) Scheduler
