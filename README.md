# kubernetes
![CI](https://github.com/academiaonline/kubernetes/workflows/CI/badge.svg?branch=main)

On Cloud9:
```
git clone https://github.com/academiaonline/kubernetes --single-branch -b main
cluster=cluster-ubuntu18-mumbai-docker-kubelet-http
location=kubernetes/etc/aws/$cluster.yaml
aws cloudformation create-stack --stack-name $cluster-$( date +%s ) --template-body file://$location --capabilities CAPABILITY_NAMED_IAM
```

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
On the worker1, worker2 and worker3:
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
