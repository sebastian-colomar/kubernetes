```
kubectl get no -o jsonpath="{.items[*].status.addresses[].address}"
```
```
kubectl config use-context cluster2
kubectl config set-context --current --namespace fusion-apd-x1df5
```
```
kubectl get po -A -o jsonpath-as-json="{.items[*].spec.containers[*].image}"
```
