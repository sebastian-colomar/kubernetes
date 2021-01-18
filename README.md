# How to install a Kubernetes cluster
![CI](https://github.com/academiaonline/kubernetes/workflows/CI/badge.svg?branch=main)

## How to create the infrastructure in AWS
On Cloud9:
```
aws configure

git clone https://github.com/academiaonline/kubernetes --single-branch -b main

# CHOOSE THE CONFIGURATION FOR YOUR CLUSTER DEPENDING ON THE OS / REGION / PROTOCOL
# https://github.com/academiaonline/kubernetes/tree/main/etc/aws
# cluster=cluster-ubuntu18-mumbai-docker-kubelet-https
cluster=cluster-ubuntu18-mumbai-docker-kubelet-http

location=kubernetes/etc/aws/$cluster.yaml
aws cloudformation create-stack --stack-name $cluster-$( date +%s ) --template-body file://$location --capabilities CAPABILITY_NAMED_IAM
```

## How to install a Kubernetes cluster with 3 masters and any number of workers
On the leader (master1):
```
git clone https://github.com/academiaonline/kubernetes --single-branch -b main
source kubernetes/bin/cluster/ubuntu18/install-leader.sh
```
On the master2 and master3:
```
git clone https://github.com/academiaonline/kubernetes --single-branch -b main

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export ip_leader=xxx
export token_certificate=xxx
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx

source kubernetes/bin/cluster/ubuntu18/install-master.sh
```
On the workers:
```
git clone https://github.com/academiaonline/kubernetes --single-branch -b main

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx
export ip_master1=xxx

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE MASTERS
export ip_master2=xxx
export ip_master3=xxx

source kubernetes/bin/cluster/ubuntu18/install-worker.sh
```

## How to install a Kubernetes cluster with 1 single master and any number of workers
On the leader (master1):
```
git clone https://github.com/academiaonline/kubernetes --single-branch -b main
source kubernetes/bin/cluster/ubuntu18/install-leader.sh
```
On the workers:
```
git clone https://github.com/academiaonline/kubernetes --single-branch -b main

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx
export ip_master1=xxx

source kubernetes/bin/cluster/ubuntu18/install-worker-singlemaster.sh
```
