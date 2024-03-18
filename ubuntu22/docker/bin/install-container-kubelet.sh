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
