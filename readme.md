
1. O Vagrantfile
Este arquivo define a infraestrutura. Note que incluí a configuração de disco de 25GB, que exige versões recentes do Vagrant.

2. Scripts de Provisionamento
Para que o cluster funcione, precisamos de um Runtime de Container (CRI). Usaremos o containerd, que é o padrão atual.

common.sh (Roda em todas as máquinas)
Este script prepara o SO, desativa o swap (exigência do K8s) e instala os binários base.

master.sh (Configura o Control Plane)
Aqui o kubeadm automatiza a criação do etcd, controller-manager e scheduler.

node.sh (Configura os Workers)

3. Como executar
Crie uma pasta para o projeto.

Salve o código do Vagrantfile dentro dela.

Crie os arquivos common.sh, master.sh e node.sh na mesma pasta.

No terminal (PowerShell), execute:
## rodar o vagrant 
## No terminal (PowerShell), execute:
vagrant up --provider virtualbox

## caso ocorram erros e precise refazer
## dentro do diretorio onde o vagrantfile está
## No Windows: Exclua o arquivo join.sh na pasta C:\projetos_vagrant\kubernetes1.
Remove-Item join.sh
vagrant destroy -f
vagrant up --provider virtualbox


4. O que este setup entrega:
- Master Node: Terá o etcd, kube-apiserver, kube-controller-manager e kube-scheduler rodando como pods estáticos (padrão kubeadm).

- Worker Nodes: Terão o kubelet e kube-proxy rodando para gerenciar os containers.

- Recursos: Cada máquina respeitará os 4GB de RAM e 2 vCPUs.

Atenção: Como você vai subir 3 VMs de 4GB, certifique-se de que sua máquina hospedeira (Windows) tenha pelo menos 16GB de RAM livres, 
caso contrário o sistema ficará extremamente lento ou as VMs falharão ao iniciar.


1. Credenciais de Acesso (Console/VirtualBox)
Se você tentar logar diretamente pela interface gráfica do VirtualBox ou se o terminal pedir senha:

Usuário: vagrant
Senha: vagrant

Nota: Para o usuário root, a senha também costuma ser vagrant, mas o padrão é utilizar o comando sudo a partir do usuário vagrant.

2. Como acessar via Terminal (Recomendado)
A forma mais fácil e correta de acessar suas VMs após o vagrant up é usando o próprio comando do Vagrant, que utiliza chaves SSH automáticas (sem pedir senha):

# obs: entrar no diretorio com o vagranfile antes
# Para acessar o Master:
vagrant ssh kbmaster

# Para acessar o Node 01:
vagrant ssh kbnode01

# Para acessar o Node 02:
vagrant ssh kbnode02

# para verificar os nodes usar o comando abaixo no Master
kubectl get nodes


3. Privilégios de Administrador
Como você precisará configurar o Kubernetes, o usuário vagrant já vem configurado com permissões de sudo sem senha.

# Para virar root dentro da VM:
sudo -i

Arquitetura do seu ClusterAgora que você tem os acessos, seu ambiente está estruturado desta forma:MáquinaIP PrivadoPapel no 
ClusterComponentes Principaismaster192.168.56.10Control Planeetcd, API Server, Scheduler, Controller Managernode01192.168.56.
11Workerkubelet, kube-proxy, container runtimenode02192.168.56.12Workerkubelet, kube-proxy, container runtime

Dica importante:
Se você acabar de subir as máquinas e tentar usar o comando kubectl get nodes no master e ele der erro de conexão, aguarde cerca de 1 a 2 
inutos. O script de provisionamento (master.sh) demora um pouco para inicializar todos os serviços do Kubernetes na primeira vez.

4. Tempo de execução
OBS: para recriar os nodes pelo vagrant up o processo todo pode dermorar uns 20 min.
aguardar até a criação do node02

========================================================================
# nova versão otimizando o tempo - não ficou bom usar o sem otimização
========================================================================

Proposta de Melhoria: VMs primeiro, Provisionamento depois
Sim, sua ideia de criar as VMs primeiro e depois instalar o Kubernetes é a melhor abordagem para estabilizar clusters locais. Isso evita  
que o Vagrant tente baixar e instalar pacotes em uma VM enquanto a outra ainda está brigando por CPU para ligar.

1. Alteração no Vagrantfile para Agilidade
Podemos aumentar ligeiramente o tempo de espera e configurar o Vagrant para não tentar subir tudo simultaneamente se o seu hardware 
estiver sofrendo.

2. Estratégia de Execução Otimizada
Para tornar o processo mais ágil e evitar os loops de erro do preflight, utilize estes comandos em sequência no seu terminal:

# Crie as VMs sem rodar os scripts (Apenas a infraestrutura): 
vagrant up --no-provision 
# Isso garante que todas as 3 VMs estejam ligadas e com a rede estável antes de qualquer instalação.

# Execute o provisionamento de forma isolada: 
vagrant provision 
# Como as máquinas já estarão "quentes" e com o hardware estabilizado, a taxa de sucesso do join será muito maior e mais rápida.

## Por que isso melhora o projeto?

Redução de Contenção: O VirtualBox consome muita CPU ao "bootar" uma VM Debian. Fazer o boot de todas primeiro garante que a CPU esteja 
livre para os scripts de instalação depois.

Rede Sincronizada: O erro de "TLS handshake" acontece quando o serviço de rede ainda não terminou de subir completamente. Com as VMs já 
ligadas, a rede 'eth1' estará pronta para o tráfego do Kubernetes imediatamente.

Podemos ajustar o tempo de sleep no seu node.sh para ser ainda mais resiliente se preferir.

# obs: para desligar a VM atual 
vagrant halt

========================================================================

Ótimo! Para que você consiga acessar o seu servidor Apache (httpd) de fora do cluster (diretamente pelo seu navegador no Windows), 
precisamos de um objeto chamado Service.

Como o seu cluster utiliza uma rede privada (192.168.56.x), usaremos o tipo NodePort. Isso fará com que o Kubernetes abra uma porta 
específica em todos os nós do cluster, encaminhando o tráfego para os seus Pods.

1. Criar o arquivo simple-service.yml
# Crie este novo arquivo na mesma pasta do seu projeto com o seguinte conteúdo:

2. Aplicar e Verificar
Execute os seguintes comandos no terminal do kbmaster:

# Aplicar o serviço: 
kubectl apply -f simple-service.yml

# Verificar se o serviço está ativo: 
kubectl get svc app-html-service

