```
kubectl get no -o jsonpath="{.items[*].status.addresses[].address}"
```
