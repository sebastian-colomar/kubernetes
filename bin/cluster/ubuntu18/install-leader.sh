#!/bin/sh
# ./bin/cluster/ubuntu18/install-leader.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set +x && test "$debug" = true && set -x                                ;
#########################################################################
ip_leader=$( ip r | grep default | awk '{ print $9 }' )                 ;
kube=kube-apiserver                                                     ;
log=/tmp/kubernetes-install.log                                         ;
sleep=10                                                                ;
#########################################################################
version="1.18.14-00"                                                    ;
calico=https://docs.projectcalico.org/v3.17/manifests/calico.yaml       ;
pod_network_cidr=192.168.0.0/16                                         ;
kubeconfig=/etc/kubernetes/admin.conf                                   ;
#########################################################################
while true                                                              ;
do                                                                      \
        sudo systemctl is-enabled kubelet                               \
        |                                                               \
        grep enabled                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
echo $ip_leader $kube | sudo tee --append /etc/hosts                    ;
sudo kubeadm init                                                       \
        --upload-certs                                                  \
        --control-plane-endpoint                                        \
                "$kube"                                                 \
        --pod-network-cidr                                              \
                $pod_network_cidr                                                   \
        --ignore-preflight-errors                                       \
                all                                                     \
        2>&1                                                            \
|                                                                       \
tee --append $log                                                       \
                                                                        ;
#########################################################################
sudo kubectl apply                                                      \
        --filename                                                      \
                $calico                                     \
        --kubeconfig                                                    \
                $kubeconfig                                             \
        2>&1                                                            \
|                                                                       \
tee --append $log                                                       \
                                                                        ;
#########################################################################
mkdir -p $HOME/.kube                                                    ;
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config                   ;
sudo chown -R $(id -u):$(id -g) $HOME/.kube/config                      ;
echo                                                                    \
        'source <(kubectl completion bash)'                             \
|                                                                       \
tee --append $HOME/.bashrc                                              \
                                                                        ;
#########################################################################
while true                                                              ;
do                                                                      \
        kubectl get node                                                \
        |                                                               \
        grep Ready                                                      \
        |                                                               \
        grep --invert-match NotReady                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
sudo sed --in-place                                                     \
        /$kube/d                                                        \
        /etc/hosts                                                      ;
sudo sed --in-place                                                     \
        /localhost4/s/$/' '$kube/                                       \
        /etc/hosts                                                      ;
#########################################################################
token="                                                                 \
        $(                                                              \
                grep --max-count 1                                      \
                        certificate-key                                 \
                        $log                                            \
        )                                                               \
"                                                                       ;
token_certificate=$(                                                    \
        echo -n $token                                                  \
        |                                                               \
        sed 's/\\/ /'                                                   \
        |                                                               \
        base64                                                          \
                --wrap 0                                                \
                                                                        ;
)                                                                       ;
#########################################################################
token="                                                                 \
        $(                                                              \
                grep --max-count 1                                      \
                        discovery-token-ca-cert-hash                    \
                        $log                                            \
        )                                                               \
"                                                                       ;
token_discovery=$(                                                      \
        echo -n $token                                                  \
        |                                                               \
        sed 's/\\/ /'                                                   \
        |                                                               \
        base64                                                          \
                --wrap 0                                                \
                                                                        ;
)                                                                       ;
#########################################################################
token="                                                                 \
        $(                                                              \
                grep --max-count 1                                      \
                        kubeadm.*join                                   \
                        $log                                            \
        )                                                               \
"                                                                       ;
token_token=$(                                                          \
        echo -n $token                                                  \
        |                                                               \
        sed 's/\\/ /'                                                   \
        |                                                               \
        base64                                                          \
                --wrap 0                                                \
                                                                        ;
)                                                                       ;
#########################################################################
echo YOU WILL NEED THE FOLLOWING TOKENS TO COMPLETE THE INSTALL         ;
echo FIRST IN THE MASTERS AND THEN IN THE WORKERS                       ;
echo export token_certificate=$token_certificate                        ;
echo export token_discovery=$token_discovery                            ;
echo export token_token=$token_token                                    ;
echo export ip_leader=$ip_leader                                        ;
echo export kube=$kube                                                  ;
echo export log=$log                                                    ;
#########################################################################

        set -x                                                                 ;
                                                                               #
        version="1.18.14-00"                                                   ;
        calico="v3.17"                                                         ;
        pod_network_cidr="192.168.0.0/16"                                      ;
                                                                               #
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg          \
        |                                                                      \
        sudo apt-key add -                                                     ;
        echo deb http://apt.kubernetes.io/ kubernetes-xenial main              \
        |                                                                      \
        sudo tee -a /etc/apt/sources.list.d/kubernetes.list                    ;
        sudo apt-get update                                                    ;
        sudo apt-get install -y --allow-downgrades                             \
          kubelet=$version kubeadm=$version kubectl=$version                   ;
        ip_leader=$( ip r | grep default | awk '{ print $9 }' )                ;
        kube=kube
        sudo swapoff -a                                                        ;
        sudo kubeadm init --apiserver-advertise-address $ip                    \
          --pod-network-cidr=$pod_network_cidr --ignore-preflight-errors=all   ;
                                                                               #
        mkdir -p $HOME/.kube                                                   ;
        sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config                  ;
        sudo chown $(id -u):$(id -g) $HOME/.kube/config                        ;
        echo "source <(kubectl completion bash)" >> ~/.bashrc                  ;
        kubectl apply -f                                                       \
          https://docs.projectcalico.org/$calico/manifests/calico.yaml         ;
        master=$( kubectl get node | grep master | awk '{ print $1 }' )        ;
                                                                               #
        kubectl taint node $master node-role.kubernetes.io/master:NoSchedule-  ;
################################################################################
