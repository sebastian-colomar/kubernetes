#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
engine=crio								;
log=/tmp/install-container-kubelet.log                                  ;
#########################################################################
echo 'deb http://deb.debian.org/debian buster-backports main' | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt update
sudo apt install -y -t buster-backports libseccomp2 || sudo apt update -y -t buster-backports libseccomp2

OS=xUbuntu_22.04
VERSION=1.24

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

sudo mkdir -p /usr/share/keyrings
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg


sudo apt-get update                                                     ;

sudo apt-get install containernetworking-plugins -y

sudo apt-get install -y cri-o cri-o-runc                                    \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo systemctl enable --now ${engine}                                   \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
sleep=10                                                                ;
version="1.18.14-00"                                                    ;
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
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg           \
|                                                                       \
sudo apt-key add -                                                      \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
echo deb http://apt.kubernetes.io/ kubernetes-xenial main               \
|                                                                       \
sudo tee -a /etc/apt/sources.list.d/kubernetes.list                     ;
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
