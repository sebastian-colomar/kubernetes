# How to install a Kubernetes cluster
![CI](https://github.com/academiaonline/kubernetes/workflows/CI/badge.svg?branch=main)

## First create the infrastructure in AWS
On Cloud9:
```
aws configure

github_username=academiaonline
github_repository=kubernetes
github_branch=main

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch}

# CHOOSE THE CONFIGURATION FOR YOUR CLUSTER DEPENDING ON THE REGION AND PROTOCOL
cluster=mumbai-kubelet-3masters-3workers-https

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

location=kubernetes/${os}/${engine}/etc/aws/${cluster}.yaml

aws cloudformation create-stack --stack-name ${os}-${engine}-${cluster}-$( date +%s ) --template-body file://${location} --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=RecordSetName,ParameterValue=kubernetes-${os}-${engine}
```

## How to install a Kubernetes cluster with 3 masters and any number of workers
On the leader (master1):
```
github_username=academiaonline
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch}
source kubernetes/${os}/${engine}/bin/install-leader.sh
```
On the master2 and master3:
```
github_username=academiaonline
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch}

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export ip_leader=xxx
export token_certificate=xxx
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx

source kubernetes/${os}/${engine}/bin/install-master.sh
```
On the workers:
```
github_username=academiaonline
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch}

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx
export ip_master1=xxx

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE MASTERS
export ip_master2=xxx
export ip_master3=xxx

source kubernetes/${os}/${engine}/bin/install-worker.sh
```

## How to install a Kubernetes cluster with 1 single master and any number of workers
On the leader (master1):
```
github_username=academiaonline
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch}
source kubernetes/${os}/${engine}/bin/install-leader.sh
```
On the workers:
```
github_username=academiaonline
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch}

# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx
export ip_master1=xxx

source kubernetes/${os}/${engine}/bin/install-worker-singlemaster.sh
```
