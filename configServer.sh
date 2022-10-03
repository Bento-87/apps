#!/bin/bash
Container() {
    echo "*********** Verificando se está rodando em um container Ubuntu"
    if [ -f /.dockerenv ];
    then
        echo "Estou em um container"
        sudoOn=""
    else
        echo "Nao estou em um container"
        sudoOn="sudo"
    fi
}

Docker() {
    echo "*********** Instalando Docker *****************"
    $sudoOn apt-get remove -y docker docker-engine docker.io containerd runc
    $sudoOn apt-get install -y ca-certificates curl gnupg lsb-release
    $sudoOn mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $sudoOn gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | $sudoOn tee /etc/apt/sources.list.d/docker.list > /dev/null
    $sudoOn apt update
    $sudoOn apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    $sudoOn groupadd docker
    $sudoOn usermod -aG docker $USER
}

Terraform (){
    echo "*********** Instalando Terraform *****************"
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | $sudoOn tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | $sudoOn tee /etc/apt/sources.list.d/hashicorp.list
    $sudoOn apt update && $sudoOn apt install terraform -y
}

Kubernetes() {
    if [ $sudoOn ];
    then
        echo "*********** Instalando Kubernetes *****************"
        $sudoOn curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
        echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | $sudoOn tee /etc/apt/sources.list.d/kubernetes.list
        $sudoOn apt update && $sudoOn apt install kubectl -y
    else 
        echo "*********** Instalando Kubernetes(Container) *****************"
        # Install kubectl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    fi
}

Awscli(){
    echo "*********** Instalando AWSCLI *****************"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    $sudoOn ./aws/install
}

Helm(){
    # Link da documentação - https://helm.sh/docs/intro/install/
    echo "*********** Instalando Helm *****************"
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    }

main() {
    Container
    echo "*********** Atualizando dados para instalação *****************"
    $sudoOn apt-get -qq update
    $sudoOn apt install unzip curl -y
    export DEBIAN_FRONTEND=noninteractive
    # Create directory to download filess
    mkdir config
    cd config
    # Calling functions
    # Docker
    # Terraform
    # Kubernetes
    # Awscli
    Helm
    # Deleting the directory
    cd ../
    $sudoOn rm -rf config
}

main