#!/bin/sh
################################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza             #
#      SPDX-License-Identifier:  GPL-2.0-only                                  #
################################################################################
        set -x                                                                 ;
                                                                               #
        version="1.18.10-00"                                                   ;
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
        ip=$( ip r | grep default | awk '{ print $9 }' )                       ;
        sudo swapoff -a                                                        ;
        sudo kubeadm init --apiserver-advertise-address $ip                    \
          --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=all      ;
                                                                               #
        mkdir -p $HOME/.kube                                                   ;
        sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config                  ;
        sudo chown $(id -u):$(id -g) $HOME/.kube/config                        ;
        echo "source <(kubectl completion bash)" >> ~/.bashrc                  ;
        kubectl apply -f                                                       \
          https://docs.projectcalico.org/v3.17/manifests/calico.yaml           ;
        master=$( kubectl get node | grep master | awk '{ print $1 }' )        ;
                                                                               #
        kubectl taint node $master node-role.kubernetes.io/master:NoSchedule-  ;
################################################################################
