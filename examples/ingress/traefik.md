```bash
kubectl create deploy web_1 --image=nginx
kubectl create deploy web_2 --image=nginx

kubectl expose deployment web_1 --type=NodePort --port=80
kubectl expose deployment web_2 --type=NodePort --port=80

tee ingress-rbac.yaml <<EOF
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: traefik
rules:
  - apiGroups:
      - ""
    resources:
      - services
      - endpoints
      - secrets
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: traefik
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: traefik
subjects:
- kind: ServiceAccount
  name: traefik
  namespace: kube-system
---
EOF

kubectl apply -f ingress-rbac.yaml

tee traefik.yaml <<EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: traefik
  namespace: kube-system
---
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: traefik
  namespace: kube-system
  labels:
    ingress: traefik
spec:
  selector:
    matchLabels:
      ingress: traefik
  template:
    metadata:
      labels:
        ingress: traefik
        name: traefik
    spec:
      serviceAccountName: traefik
      terminationGracePeriodSeconds: 60
      hostNetwork: True
      containers:
      - image: traefik:1.7.13
        name: traefik
        ports:
        - name: http
          containerPort: 80
          hostPort: 80
        - name: admin
          containerPort: 8080
          hostPort: 8080
        args:
        - --api
        - --kubernetes
        - --logLevel=INFO
---
kind: Service
apiVersion: v1
metadata:
  name: traefik
  namespace: kube-system
spec:
  selector:
    ingress: traefik
  ports:
    - protocol: TCP
      port: 80
      name: web
    - protocol: TCP
      port: 8080
      name: admin
---
EOF

kubectl apply -f traefik.yaml

tee ingress-rule.yaml <<EOF
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: www.web_1.com
    http:
      paths:
      - backend:
          serviceName: web_1
          servicePort: 80
        path: /
  - host: www.web_2.com
    http:
      paths:
      - backend:
          serviceName: web_2
          servicePort: 80
        path: /
---
EOF

kubectl apply -f ingress-rule.yaml
