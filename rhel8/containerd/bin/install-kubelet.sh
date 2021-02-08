#!/bin/sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set -x                                                                  ;
#########################################################################
baseurl=https://packages.cloud.google.com				;
engine=containerd							;
log=/tmp/install-container-kubelet.log                                  ;
repo=https://download.docker.com/linux/centos/docker-ce.repo		;
rpm_key=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg	;
sleep=10                                                                ;
version="1.18.14-00"                                                    ;
yum_key=https://packages.cloud.google.com/yum/doc/yum-key.gpg		;
#########################################################################
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=${baseurl}/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=${yum_key} ${rpm_key}
exclude=kubelet kubeadm kubectl
EOF
#########################################################################
sudo setenforce 0							;
sudo sed -i /^SELINUX/s/enforcing/permissive/ /etc/selinux/config	;
#########################################################################
sudo yum install -y --disableexcludes=kubernetes                        \
        kubeadm-${version} kubectl-${version} kubelet-${version}        \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo systemctl enable --now kubelet                                     \
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
