#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
engine=docker								;
log=/tmp/install-container-kubelet.log                                  ;
#########################################################################
sudo apt-get update                                                     ;
sudo apt-get install -y ${engine}.io                                    \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo systemctl enable --now ${engine}                                   \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
sleep=10                                                                ;
version=1.24.17-1.1                                                    ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl status ${engine}                                      \
        |                                                               \
        grep running                                                    \
        &&                                                              \
        break                                                           ;
        sleep $sleep                                                    ;
done                                                                    ;
#########################################################################
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key           \
|                                                                       \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg                                                      \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.24/deb/ /'               \
|                                                                       \
sudo tee /etc/apt/sources.list.d/kubernetes.list                     ;
sudo apt-get update                                                     \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo apt-get install -y --allow-downgrades                              \
        kubelet=$version kubeadm=$version kubectl=$version              \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo systemctl enable --now kubelet                                     \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
