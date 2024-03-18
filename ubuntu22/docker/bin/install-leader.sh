#!/bin/sh
# ./bin/cluster/ubuntu18/install-leader.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
ip_leader=$( ip r | grep -v docker | awk '/kernel/{ print $9 }' )       ;
kube=kube-apiserver                                                     ;
log=/tmp/install-leader.log                                             ;
sleep=10                                                                ;
#########################################################################
calico=https://docs.projectcalico.org/v3.21/manifests/calico.yaml       ;
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
echo $ip_leader $kube                                                   \
|                                                                       \
sudo tee --append /etc/hosts                                            ;
sudo swapoff --all                                                      ;
sudo kubeadm init                                                       \
        --upload-certs                                                  \
        --control-plane-endpoint                                        \
                "$kube"                                                 \
        --pod-network-cidr                                              \
                $pod_network_cidr                                       \
        --ignore-preflight-errors                                       \
                all                                                     \
        2>&1                                                            \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
sudo kubectl apply                                                      \
        --filename                                                      \
                $calico                                                 \
        --kubeconfig                                                    \
                $kubeconfig                                             \
        2>&1                                                            \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
mkdir -p $HOME/.kube                                                    ;
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config                   ;
sudo chown -R $(id -u):$(id -g) $HOME/.kube/                            ;
echo 'source <(kubectl completion bash)'                                \
|                                                                       \
tee --append $HOME/.bashrc                                              ;
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
        /127.0.0.1.*localhost/s/$/' '$kube/                             \
        /etc/hosts                                                      ;
#########################################################################
token="$( grep --max-count 1 certificate-key $log )"                    ;
token_certificate=$(                                                    \
        echo -n $token                                                  \
        |                                                               \
        sed 's/\\/ /'                                                   \
        |                                                               \
        base64 --wrap 0                                                 \
)                                                                       ;
#########################################################################
token="$( grep --max-count 1 discovery-token-ca-cert-hash $log )"       ;
token_discovery=$(                                                      \
        echo -n $token                                                  \
        |                                                               \
        sed 's/\\/ /'                                                   \
        |                                                               \
        base64 --wrap 0                                                 \
)                                                                       ;
#########################################################################
token="$( grep --max-count 1 kubeadm.*join $log )"                      ;
token_token=$(                                                          \
        echo -n $token                                                  \
        |                                                               \
        sed 's/\\/ /'                                                   \
        |                                                               \
        base64 --wrap 0                                                 \
)                                                                       ;
#########################################################################
echo YOU WILL NEED THE FOLLOWING TOKENS TO COMPLETE THE INSTALL         \
|                                                                       \
tee --append $log                                                       ;
echo FIRST IN THE MASTERS AND THEN IN THE WORKERS                       \
|                                                                       \
tee --append $log                                                       ;
echo export ip_leader=$ip_leader                                        \
|                                                                       \
tee --append $log                                                       ;
echo export token_certificate=$token_certificate                        \
|                                                                       \
tee --append $log                                                       ;
echo export token_discovery=$token_discovery                            \
|                                                                       \
tee --append $log                                                       ;
echo export token_token=$token_token                                    \
|                                                                       \
tee --append $log                                                       ;
echo export kube=$kube                                                  \
|                                                                       \
tee --append $log                                                       ;
echo export ip_master1=$ip_leader                                       \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
tail $log                                                               ;
#########################################################################
