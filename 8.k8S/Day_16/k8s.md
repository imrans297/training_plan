# My Kubernetes Journey - Complete Guide

## What is Kubernetes?

Kubernetes (k8s) is a container orchestration platform that automates deployment, scaling, and management of containerized applications. Think of it as a smart manager that takes care of your containers across multiple machines.

**Before Kubernetes:**
- Manual container deployment
- No automatic scaling
- Complex load balancing setup
- Manual health checks and restarts
- Nightmare during server failures

**After Kubernetes:**
- Declarative deployments
- Automatic scaling based on load
- Built-in service discovery and load balancing
- Self-healing applications
- Zero-downtime deployments

## Kubernetes Architecture

Understanding the architecture helped me troubleshoot issues better. Here's how I visualize it:

### Control Plane (Master Node)
The brain of the cluster:

**API Server (kube-apiserver)**
- Entry point for all REST commands
- Validates and processes API requests
- I interact with this through kubectl

**etcd**
- Distributed key-value store
- Stores all cluster data
- Think of it as the cluster's database

**Scheduler (kube-scheduler)**
- Decides which node runs which pod
- Considers resource requirements and constraints

**Controller Manager (kube-controller-manager)**
- Runs various controllers
- Ensures desired state matches actual state

### Worker Nodes
Where the actual work happens:

**kubelet**
- Node agent that communicates with control plane
- Manages pods and containers on the node

**kube-proxy**
- Network proxy running on each node
- Handles network routing for services

**Container Runtime**
- Docker, containerd, or CRI-O
- Actually runs the containers

### My Mental Model
```
Control Plane (Master)
├── API Server (kubectl talks to this)
├── etcd (stores everything)
├── Scheduler (decides placement)
└── Controller Manager (maintains state)

Worker Nodes
├── kubelet (node agent)
├── kube-proxy (networking)
└── Container Runtime (runs containers)
```

## Setting Up Kubernetes

### Local Development Setup

For learning, I started with these options:

**minikube** (My favorite for learning)
```bash
# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start cluster
minikube start

# Check status
minikube status
```

**kind** (Kubernetes in Docker)
```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create cluster
kind create cluster --name my-cluster

# Delete cluster
kind delete cluster --name my-cluster
```

### Installing kubectl

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable and move
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### Production Setup (kubeadm)

For production clusters, I use kubeadm:

```bash
# On all nodes - install container runtime (Docker/containerd)
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install kubeadm, kubelet, kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# On master node - initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubectl for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network plugin (Flannel)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# On worker nodes - join cluster (use token from init output)
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

## Core Kubernetes Objects

### Pods - The Basic Unit

A Pod is the smallest deployable unit. I rarely create pods directly, but understanding them is crucial.

```yaml
# simple-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  containers:
  - name: app-container
    image: nginx:1.20
    ports:
    - containerPort: 80
```

```bash
# Create pod
kubectl apply -f simple-pod.yaml

# Check pod status
kubectl get pods

# Describe pod (great for debugging)
kubectl describe pod my-app

# Get pod logs
kubectl logs my-app

# Execute command in pod
kubectl exec -it my-app -- /bin/bash

# Delete pod
kubectl delete pod my-app
```

### Deployments - Managing Pod Replicas

Deployments are what I use 90% of the time. They manage ReplicaSets, which manage Pods.

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

```bash
# Create deployment
kubectl apply -f nginx-deployment.yaml

# Check deployment status
kubectl get deployments

# Check replica sets
kubectl get rs

# Check pods created by deployment
kubectl get pods -l app=nginx

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5

# Update image (rolling update)
kubectl set image deployment/nginx-deployment nginx=nginx:1.21

# Check rollout status
kubectl rollout status deployment/nginx-deployment

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Check rollout history
kubectl rollout history deployment/nginx-deployment
```

### Services - Networking and Discovery

Services provide stable networking for pods. I use different types based on needs:

**ClusterIP** (Internal access only)
```yaml
# nginx-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

**NodePort** (External access via node IP)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
```

**LoadBalancer** (Cloud provider load balancer)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-lb
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

```bash
# Create service
kubectl apply -f nginx-service.yaml

# Check services
kubectl get svc

# Describe service
kubectl describe svc nginx-service

# Test service (from inside cluster)
kubectl run test-pod --image=busybox -it --rm -- wget -qO- nginx-service
```

### ConfigMaps and Secrets

For configuration management, I use ConfigMaps for non-sensitive data and Secrets for sensitive data.

**ConfigMap Example:**
```yaml
# app-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://db:5432/myapp"
  debug_mode: "true"
  app.properties: |
    server.port=8080
    logging.level=INFO
```

**Secret Example:**
```yaml
# app-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded 'admin'
  password: cGFzc3dvcmQ=  # base64 encoded 'password'
```

**Using in Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-app:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_url
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: password
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: app-config
```

```bash
# Create configmap from file
kubectl create configmap app-config --from-file=config.properties

# Create configmap from literal values
kubectl create configmap app-config --from-literal=key1=value1 --from-literal=key2=value2

# Create secret from literal values
kubectl create secret generic app-secrets --from-literal=username=admin --from-literal=password=secret

# View configmap
kubectl get configmap app-config -o yaml

# View secret (base64 encoded)
kubectl get secret app-secrets -o yaml
```

## Persistent Storage

### Persistent Volumes and Claims

For stateful applications, I need persistent storage:

**Persistent Volume (PV):**
```yaml
# pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /data/my-pv
```

**Persistent Volume Claim (PVC):**
```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```

**Using PVC in Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          value: user
        - name: POSTGRES_PASSWORD
          value: password
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: my-pvc
```

```bash
# Check persistent volumes
kubectl get pv

# Check persistent volume claims
kubectl get pvc

# Describe PVC for troubleshooting
kubectl describe pvc my-pvc
```

## Namespaces - Organizing Resources

Namespaces help me organize resources and implement resource quotas:

```bash
# Create namespace
kubectl create namespace development
kubectl create namespace production

# List namespaces
kubectl get namespaces

# Set default namespace for kubectl
kubectl config set-context --current --namespace=development

# Create resources in specific namespace
kubectl apply -f deployment.yaml -n development

# Get resources from specific namespace
kubectl get pods -n development

# Get resources from all namespaces
kubectl get pods --all-namespaces
```

**Namespace with Resource Quota:**
```yaml
# namespace-with-quota.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
```

## Ingress - External Access

For HTTP/HTTPS routing, I use Ingress controllers:

**Install NGINX Ingress Controller:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
```

**Ingress Resource:**
```yaml
# my-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
  - host: api.myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

**With TLS:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - myapp.local
    secretName: tls-secret
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

## StatefulSets - For Stateful Applications

When I need ordered deployment and stable network identities:

```yaml
# postgres-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          value: user
        - name: POSTGRES_PASSWORD
          value: password
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
```

## DaemonSets - One Pod Per Node

For node-level services like monitoring agents:

```yaml
# node-exporter-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
```

## Jobs and CronJobs

For batch processing and scheduled tasks:

**Job Example:**
```yaml
# backup-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: database-backup
spec:
  template:
    spec:
      containers:
      - name: backup
        image: postgres:13
        command: ["pg_dump"]
        args: ["-h", "postgres", "-U", "user", "myapp"]
        env:
        - name: PGPASSWORD
          value: "password"
      restartPolicy: Never
  backoffLimit: 4
```

**CronJob Example:**
```yaml
# cleanup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-job
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: busybox
            command: ["sh", "-c", "echo 'Cleaning up old files'; find /tmp -type f -mtime +7 -delete"]
          restartPolicy: OnFailure
```

## Horizontal Pod Autoscaler (HPA)

For automatic scaling based on metrics:

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

```bash
# Create HPA
kubectl apply -f hpa.yaml

# Check HPA status
kubectl get hpa

# Describe HPA
kubectl describe hpa nginx-hpa

# Generate load to test scaling
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Inside the pod:
while true; do wget -q -O- http://nginx-service; done
```

## Essential kubectl Commands

### Basic Operations
```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get all resources
kubectl get all

# Get resources with labels
kubectl get pods --show-labels

# Get resources with specific label
kubectl get pods -l app=nginx

# Watch resources (real-time updates)
kubectl get pods -w

# Get resource in different output formats
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json
```

### Debugging Commands
```bash
# Describe resource (great for troubleshooting)
kubectl describe pod my-pod

# Get logs
kubectl logs my-pod
kubectl logs my-pod -c container-name  # multi-container pod
kubectl logs -f my-pod  # follow logs
kubectl logs --previous my-pod  # previous container logs

# Execute commands in pod
kubectl exec my-pod -- ls /
kubectl exec -it my-pod -- /bin/bash

# Port forwarding (access pod locally)
kubectl port-forward pod/my-pod 8080:80
kubectl port-forward service/my-service 8080:80

# Copy files
kubectl cp my-pod:/path/to/file ./local-file
kubectl cp ./local-file my-pod:/path/to/file
```

### Resource Management
```bash
# Apply configuration
kubectl apply -f deployment.yaml
kubectl apply -f .  # all files in directory
kubectl apply -k .  # kustomize

# Delete resources
kubectl delete -f deployment.yaml
kubectl delete pod my-pod
kubectl delete deployment my-deployment

# Edit resource
kubectl edit deployment my-deployment

# Patch resource
kubectl patch deployment my-deployment -p '{"spec":{"replicas":5}}'

# Scale deployment
kubectl scale deployment my-deployment --replicas=3

# Rollout operations
kubectl rollout status deployment/my-deployment
kubectl rollout history deployment/my-deployment
kubectl rollout undo deployment/my-deployment
```

### Context and Configuration
```bash
# View current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-context

# Set namespace for current context
kubectl config set-context --current --namespace=my-namespace

# View kubeconfig
kubectl config view
```

## Real-World Application Example

Here's a complete example of a web application with database:

**Namespace:**
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: webapp
```

**Database (PostgreSQL):**
```yaml
# postgres.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: webapp
type: Opaque
data:
  username: cG9zdGdyZXM=  # postgres
  password: cGFzc3dvcmQ=  # password
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: webapp
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: webapp
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        ports:
        - containerPort: 5432
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: webapp
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

**Web Application:**
```yaml
# webapp.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config
  namespace: webapp
data:
  DATABASE_HOST: postgres-service
  DATABASE_NAME: webapp
  DEBUG: "false"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: my-webapp:latest
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: webapp-config
              key: DATABASE_HOST
        - name: DATABASE_NAME
          valueFrom:
            configMapKeyRef:
              name: webapp-config
              key: DATABASE_NAME
        - name: DATABASE_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: username
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: webapp
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  namespace: webapp
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: webapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
```

**Deploy the application:**
```bash
# Create namespace
kubectl apply -f namespace.yaml

# Deploy database
kubectl apply -f postgres.yaml

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n webapp --timeout=300s

# Deploy web application
kubectl apply -f webapp.yaml

# Check deployment status
kubectl get all -n webapp

# Test the application
kubectl port-forward service/webapp-service 8080:80 -n webapp
# Then visit http://localhost:8080
```

## Monitoring and Logging

### Resource Monitoring
```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods

# Check pod resource usage in specific namespace
kubectl top pods -n webapp

# Get detailed resource information
kubectl describe node node-name
```

### Application Logs
```bash
# View logs from all pods with label
kubectl logs -l app=webapp -n webapp

# Stream logs from multiple pods
kubectl logs -f -l app=webapp -n webapp

# View logs from previous container (if crashed)
kubectl logs webapp-pod --previous -n webapp
```

## Troubleshooting Common Issues

### Pod Issues

**Pod stuck in Pending:**
```bash
# Check events
kubectl describe pod pod-name

# Common causes:
# - Insufficient resources
# - Node selector not matching
# - PVC not bound
# - Image pull issues
```

**Pod stuck in CrashLoopBackOff:**
```bash
# Check logs
kubectl logs pod-name --previous

# Check resource limits
kubectl describe pod pod-name

# Common causes:
# - Application crashes on startup
# - Liveness probe failing
# - Resource limits too low
```

**ImagePullBackOff:**
```bash
# Check events
kubectl describe pod pod-name

# Common causes:
# - Image doesn't exist
# - Registry authentication issues
# - Network issues
```

### Service Issues

**Service not accessible:**
```bash
# Check service endpoints
kubectl get endpoints service-name

# Check if pods are ready
kubectl get pods -l app=your-app

# Test service from inside cluster
kubectl run test-pod --image=busybox -it --rm -- wget -qO- service-name
```

### Networking Issues

**DNS resolution problems:**
```bash
# Test DNS from pod
kubectl exec -it pod-name -- nslookup kubernetes.default

# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

### Storage Issues

**PVC stuck in Pending:**
```bash
# Check PVC status
kubectl describe pvc pvc-name

# Check available PVs
kubectl get pv

# Check storage class
kubectl get storageclass
```

## Security Best Practices

### RBAC (Role-Based Access Control)

```yaml
# service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webapp-sa
  namespace: webapp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: webapp-role
  namespace: webapp
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: webapp-rolebinding
  namespace: webapp
subjects:
- kind: ServiceAccount
  name: webapp-sa
  namespace: webapp
roleRef:
  kind: Role
  name: webapp-role
  apiGroup: rbac.authorization.k8s.io
```

### Pod Security

```yaml
# secure-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  serviceAccountName: webapp-sa
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app
    image: my-app:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Network Policies

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: webapp-netpol
  namespace: webapp
spec:
  podSelector:
    matchLabels:
      app: webapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to: []  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
```

## Performance Optimization

### Resource Requests and Limits

Always set resource requests and limits:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### Horizontal Pod Autoscaler

```bash
# Enable metrics server (if not already enabled)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Create HPA
kubectl autoscale deployment webapp --cpu-percent=70 --min=2 --max=10
```

### Vertical Pod Autoscaler

```yaml
# vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: webapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Auto"
```

## Useful Tools and Add-ons

### Helm - Package Manager

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add repository
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Install application
helm install my-release stable/nginx

# List releases
helm list

# Upgrade release
helm upgrade my-release stable/nginx

# Uninstall release
helm uninstall my-release
```

### Kustomize - Configuration Management

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml

patchesStrategicMerge:
- patch.yaml

images:
- name: my-app
  newTag: v2.0.0

replicas:
- name: my-deployment
  count: 5
```

```bash
# Apply with kustomize
kubectl apply -k .

# Preview changes
kubectl diff -k .
```

### Useful kubectl Plugins

```bash
# Install krew (plugin manager)
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
tar zxvf krew-linux_amd64.tar.gz
./krew-linux_amd64 install krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Install useful plugins
kubectl krew install ctx  # switch contexts
kubectl krew install ns   # switch namespaces
kubectl krew install tree # show resource hierarchy
kubectl krew install tail # tail logs from multiple pods
```

## My Daily Kubernetes Workflow

### Development Workflow
```bash
# 1. Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# 2. Switch to development namespace
kubectl config set-context --current --namespace=development

# 3. Deploy changes
kubectl apply -f .

# 4. Check deployment status
kubectl get pods -w

# 5. Check logs if issues
kubectl logs -f deployment/my-app

# 6. Test application
kubectl port-forward service/my-app 8080:80
```

### Production Deployment
```bash
# 1. Validate manifests
kubectl apply --dry-run=client -f .

# 2. Apply changes
kubectl apply -f .

# 3. Monitor rollout
kubectl rollout status deployment/my-app

# 4. Verify deployment
kubectl get pods
kubectl logs deployment/my-app

# 5. Run smoke tests
kubectl run test --image=busybox -it --rm -- wget -qO- my-service
```

### Troubleshooting Workflow
```bash
# 1. Check overall cluster health
kubectl get nodes
kubectl get pods --all-namespaces | grep -v Running

# 2. Investigate specific issues
kubectl describe pod problematic-pod
kubectl logs problematic-pod --previous

# 3. Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# 4. Check resource usage
kubectl top nodes
kubectl top pods

# 5. Network debugging
kubectl exec -it debug-pod -- nslookup service-name
kubectl exec -it debug-pod -- telnet service-name port
```

This guide covers most of what I use Kubernetes for in my daily work. The key is to start with simple deployments and gradually add complexity as you become more comfortable with the concepts. Remember, Kubernetes has a steep learning curve, but once you get the hang of it, it makes managing containerized applications much easier.