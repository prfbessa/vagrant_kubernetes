
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

