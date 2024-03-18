# How to install a Kubernetes cluster
![CI](https://github.com/sebastian-colomar/kubernetes/workflows/CI/badge.svg?branch=main)

You need to run a BASH shell. You can do it as root or as a normal user:
```
sudo su --login root

```
Remove unwanted aliases if necessary:
```
unalias rm cp mv

```
Check that you have the necessary AWS credentials available:
```
aws configure

```
Install git and docker if not yet available:
```
sudo yum install -y docker git
sudo systemctl enable --now docker

```
## First create the infrastructure in AWS
On Cloud9:
```
dir=${HOME}/environment
github_username=sebastian-colomar
github_repository=kubernetes
github_branch=ubuntu-22_kubernetes-1.29

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch} ${dir}/${github_repository}

# CHOOSE THE CONFIGURATION FOR YOUR CLUSTER DEPENDING ON THE REGION AND PROTOCOL
cluster=mumbai-kubelet-3masters-3workers-https

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu22

# CHOOSE YOUR CONTAINER ENGINE
engine=docker
engine=containerd
engine=cri-o

location=${dir}/${github_repository}/${os}/${engine}/etc/aws/${cluster}.yaml

aws cloudformation create-stack --stack-name ${os}-${engine}-${cluster}-$( date +%s ) --template-body file://${location} --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=RecordSetName,ParameterValue=kubernetes-${os}-${engine}
```

## How to install a Kubernetes cluster with 3 masters and any number of workers
On the leader (master1):
```
bash
dir=/tmp
github_username=sebastian-colomar
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch} ${dir}/${github_repository}
source ${dir}/${github_repository}/${os}/${engine}/bin/install-leader.sh
```
On the master2 and master3:
```
bash
dir=/tmp
github_username=sebastian-colomar
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch} ${dir}/${github_repository}
```
```
# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export ip_leader=xxx
export token_certificate=xxx
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx
```
```
source ${dir}/${github_repository}/${os}/${engine}/bin/install-master.sh
```
On the workers:
```
bash
dir=/tmp
github_username=sebastian-colomar
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch} ${dir}/${github_repository}
```
```
# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx
export ip_master1=xxx
```
```
# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE MASTERS
export ip_master2=xxx
export ip_master3=xxx
```
```
source ${dir}/${github_repository}/${os}/${engine}/bin/install-worker.sh
```

## How to install a Kubernetes cluster with 1 single master and any number of workers
On the leader (master1):
```
bash
dir=/tmp
github_username=sebastian-colomar
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch} ${dir}/${github_repository}
source ${dir}/${github_repository}/${os}/${engine}/bin/install-leader.sh
```
On the workers:
```
bash
dir=/tmp
github_username=sebastian-colomar
github_repository=kubernetes
github_branch=main

# CHOOSE YOUR OPERATING SYSTEM
os=rhel8
os=ubuntu18

# CHOOSE YOUR CONTAINER ENGINE
engine=containerd
engine=cri-o
engine=docker

git clone https://github.com/${github_username}/${github_repository} --single-branch -b ${github_branch} ${dir}/${github_repository}
```
```
# EXPORT THE FOLLOWING VARIABLES FROM THE OUTPUT OF THE LEADER
export token_discovery=xxx
export token_token=xxx
export kube=kube-xxx
export ip_master1=xxx
```
```
source ${dir}/${github_repository}/${os}/${engine}/bin/install-worker-singlemaster.sh
```
