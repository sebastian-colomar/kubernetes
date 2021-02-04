#!/bin/sh
# ./rhel8/containerd/bin/install-container-kubelet.sh
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
#sudo yum update -y							;
sudo yum install -y python3						;
region=$( 								\
	curl -s 							\
	http://169.254.169.254/latest/dynamic/instance-identity/document\
	|								\
	awk -F '"' /region/'{ print $4 }' 				\
)									;
path=amazon-ssm-${region}/latest/linux_amd64/amazon-ssm-agent.rpm	;
sudo yum install -y 							\
	https://s3.${region}.amazonaws.com/${path}			;
#########################################################################
sudo tee /etc/modules-load.d/${engine}.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay							;
sudo modprobe br_netfilter						;
#########################################################################
sudo tee /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system							;
#########################################################################
sudo yum install -y yum-utils device-mapper-persistent-data lvm2	;
sudo yum-config-manager --add-repo ${repo}				;
sudo yum install -y ${engine}.io					\
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo mkdir -p /etc/containerd						;
containerd config default | sudo tee /etc/containerd/config.toml	;
sudo systemctl restart ${engine}					\
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
sudo systemctl enable --now ${engine}					\
        2>& 1                                                           \
|                                                                       \
tee --append $log                                                       ;
#########################################################################
while true                                                              ;
do                                                                      \
        systemctl status ${engine}                                      \
        |                                                               \
        grep running                                                    \
        &&                                                              \
        break                                                           \
                                                                        ;
        sleep $sleep                                                    ;
done                                                                    ;
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
