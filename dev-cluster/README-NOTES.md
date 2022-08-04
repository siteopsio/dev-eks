# Scratch Notes

## 

## Deploy sample app - aws example
https://docs.aws.amazon.com/eks/latest/userguide/sample-deployment.html

* Create Namespace
    * ```kubectl create namespace eks-sample-app```

* Create Kuberneties Deployment - eks-sample-deployment.yaml
    * ```kubectl apply -f eks-sample-deployment.yaml```

* Delete pods and services based on label
  * ```kubectl delete pods,services -l env=dev```
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eks-sample-linux-deployment
  namespace: eks-sample-app
  labels:
    app: eks-sample-linux-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: eks-sample-linux-app
  template:
    metadata:
      labels:
        app: eks-sample-linux-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                - amd64
                - arm64
      containers:
      - name: nginx
        image: public.ecr.aws/nginx/nginx:1.21
        ports:
        - name: http
          containerPort: 80
        imagePullPolicy: IfNotPresent
      nodeSelector:
        kubernetes.io/os: linux
```

* Create a Service - eks-sample-service.yaml
    * ```kubectl apply -f eks-sample-service.yaml```
```
apiVersion: v1
kind: Service
metadata:
  name: eks-sample-linux-service
  namespace: eks-sample-app
  labels:
    app: eks-sample-linux-app
spec:
  selector:
    app: eks-sample-linux-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```      
