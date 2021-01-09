#!/bin/bash -x
#	./bin/kubelet/ubuntu18/install.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set +x && test "$debug" = true && set -x                                ;
#########################################################################
version="1.18.14-00"                                                    ;
sleep=10                                                                ;
#########################################################################
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg           ;
|                                                                       \
sudo apt-key add -                                                      ;
echo deb http://apt.kubernetes.io/ kubernetes-xenial main               \
|                                                                       \
sudo tee -a /etc/apt/sources.list.d/kubernetes.list                     ;
sudo apt-get update                                                     ;
sudo apt-get install -y --allow-downgrades                              \
        kubelet=$version kubeadm=$version kubectl=$version              ;
sudo systemctl enable --now	kubelet                                 ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl is-enabled kubelet                                    \
        |                                                               \
        grep enabled                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
