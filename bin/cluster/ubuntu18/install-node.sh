#!/bin/sh
# ./bin/cluster/ubuntu18/install-node.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
sudo apt-get update                                                     ;
sudo apt-get install -y docker.io                                       ;
sudo systemctl enable --now docker                                      ;
#########################################################################
version="1.18.14-00"                                                    ;
sleep=10                                                                ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl status docker                                         \
        |                                                               \
        grep running                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg           \
|                                                                       \
sudo apt-key add -                                                      ;
echo deb http://apt.kubernetes.io/ kubernetes-xenial main               \
|                                                                       \
sudo tee -a /etc/apt/sources.list.d/kubernetes.list                     ;
sudo apt-get update                                                     ;
sudo apt-get install -y --allow-downgrades                              \
        kubelet=$version kubeadm=$version kubectl=$version              ;
sudo systemctl enable --now kubelet                                     ;
#########################################################################
