# AKS Cluster with DataDog Integration - Complete Documentation

## Table of Contents
1. [AKS Cluster Overview](#aks-cluster-overview)
2. [Application Architecture](#application-architecture)
3. [Kubernetes Resources](#kubernetes-resources)
4. [Application Testing](#application-testing)
5. [DataDog Integration](#datadog-integration)
6. [DataDog Monitoring Views](#datadog-monitoring-views)
7. [Troubleshooting](#troubleshooting)

---

## 1. AKS Cluster Overview

### 1.1 Cluster Information
- **Cluster Name**: Voting-app
- **Resource Group**: VotingApp
- **Node Count**: 2 worker nodes
- **Kubernetes Version**: 1.32.6
- **Location**: Southeast Asia 

### 1.2 AKS Cluster Dashboard
![alt text](image.png)



### 1.3 Node Information
```bash
kubectl get nodes -o wide
```
![alt text](image-1.png)

### 1.4 Cluster Resources
```bash
kubectl get all --all-namespaces
```
![alt text](image-2.png)

![alt text](image-3.png)

---

## 2. Application Architecture

### 2.1 Voting Application Components
- **Vote App**: Python Flask frontend (Cats vs Dogs voting)
- **Result App**: Node.js results display
- **Worker App**: .NET vote processor
- **Database**: PostgreSQL
- **Cache**: Redis

---

## 3. Kubernetes Resources

### 3.1 Deployments

#### Vote App Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vote
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vote
  template:
    metadata:
      labels:
        app: vote
    spec:
      containers:
      - name: vote
        image: dockersamples/examplevotingapp_vote
        ports:
        - containerPort: 80
```

![alt text](image-4.png)

#### Result App Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: result
spec:
  replicas: 1
  selector:
    matchLabels:
      app: result
  template:
    metadata:
      labels:
        app: result
    spec:
      containers:
      - name: result
        image: dockersamples/examplevotingapp_result
        ports:
        - containerPort: 80
```

![alt text](image-5.png)

#### Worker App Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
      - name: worker
        image: dockersamples/examplevotingapp_worker
```

![alt text](image-6.png)

### 3.2 Services

#### LoadBalancer Services
```yaml
# Vote Service
apiVersion: v1
kind: Service
metadata:
  name: vote
spec:
  type: LoadBalancer
  ports:
  - port: 8080
    targetPort: 80
  selector:
    app: vote

---
# Result Service
apiVersion: v1
kind: Service
metadata:
  name: result
spec:
  type: LoadBalancer
  ports:
  - port: 8081
    targetPort: 80
  selector:
    app: result
```

![alt text](image-7.png)

#### ClusterIP Services
```yaml
# Database Service
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  type: ClusterIP
  ports:
  - port: 5432
  selector:
    app: db

---
# Redis Service
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  type: ClusterIP
  ports:
  - port: 6379
  selector:
    app: redis
```

![alt text](image-8.png)

### 3.3 Pods Status
```bash
kubectl get pods -o wide
```
![alt text](image-9.png)

### 3.4 Pod Details
```bash
kubectl describe pod <pod-name>
```
![Pod Details](screenshots/pod-details.png)
*Screenshot: Detailed pod information*
```
kubectl describe pods
Name:             db-74574d66dd-dmz5c
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-agentpool-26539386-vmss000000/10.224.0.4
Start Time:       Wed, 10 Sep 2025 12:40:45 +0530
Labels:           app=db
                  pod-template-hash=74574d66dd
Annotations:      <none>
Status:           Running
IP:               10.244.0.245
IPs:
  IP:           10.244.0.245
Controlled By:  ReplicaSet/db-74574d66dd
Containers:
  postgres:
    Container ID:   containerd://22d788f80fd2872073cc3cdcfe9faf48bf459e9994918ca23d84cf01ef88d23a
    Image:          postgres:15-alpine
    Image ID:       docker.io/library/postgres@sha256:dfcf0459185089e88a43197975780f5a3078acd5ece84824a14c9d6fbbab02d0
    Port:           5432/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 10 Sep 2025 12:41:00 +0530
    Ready:          True
    Restart Count:  0
    Environment:
      POSTGRES_USER:      postgres
      POSTGRES_PASSWORD:  postgres
    Mounts:
      /var/lib/postgresql/data from db-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-s972z (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  db-data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-s972z:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:             redis-6c5fb9c4b7-2bt76
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-agentpool-26539386-vmss000000/10.224.0.4
Start Time:       Wed, 10 Sep 2025 12:40:46 +0530
Labels:           app=redis
                  pod-template-hash=6c5fb9c4b7
Annotations:      <none>
Status:           Running
IP:               10.244.0.175
IPs:
  IP:           10.244.0.175
Controlled By:  ReplicaSet/redis-6c5fb9c4b7
Containers:
  redis:
    Container ID:   containerd://4a083b57887400fa514fe9fa86316707fc4330712ceda553d31430fc458a88b8
    Image:          redis:alpine
    Image ID:       docker.io/library/redis@sha256:987c376c727652f99625c7d205a1cba3cb2c53b92b0b62aade2bd48ee1593232
    Port:           6379/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 10 Sep 2025 12:40:56 +0530
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from redis-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vfw8q (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  redis-data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-vfw8q:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:             result-5df7f4dfb5-vxck2
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-agentpool-26539386-vmss000000/10.224.0.4
Start Time:       Wed, 10 Sep 2025 15:59:51 +0530
Labels:           app=result
                  pod-template-hash=5df7f4dfb5
Annotations:      admission.datadoghq.com/js-lib.version: latest
Status:           Running
IP:               10.244.0.130
IPs:
  IP:           10.244.0.130
Controlled By:  ReplicaSet/result-5df7f4dfb5
Containers:
  result:
    Container ID:   containerd://4c0a2e2dfe4ef36334be658d4cbf668e3894c2385eb63b9905ee10e940e2599d
    Image:          dockersamples/examplevotingapp_result
    Image ID:       docker.io/dockersamples/examplevotingapp_result@sha256:06c50992ab258e1d83406784040842bb920f6938eabac19261e7ec634f878935
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 10 Sep 2025 15:59:54 +0530
    Ready:          True
    Restart Count:  0
    Environment:
      DD_TRACE_ENABLED:    true
      DD_AGENT_HOST:        (v1:status.hostIP)
      DD_SERVICE:          result-app
      DD_ENV:              production
      DD_VERSION:          1.0.0
      DD_TRACE_AGENT_URL:  http://$(DD_AGENT_HOST):8126
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-fh5qn (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-fh5qn:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:             vote-5bcdc79ddd-bdm6b
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-agentpool-26539386-vmss000001/10.224.0.5
Start Time:       Wed, 10 Sep 2025 15:59:51 +0530
Labels:           app=vote
                  pod-template-hash=5bcdc79ddd
Annotations:      admission.datadoghq.com/python-lib.version: latest
Status:           Running
IP:               10.244.1.202
IPs:
  IP:           10.244.1.202
Controlled By:  ReplicaSet/vote-5bcdc79ddd
Containers:
  vote:
    Container ID:   containerd://c2d56b235a7ca13ea634f109f168071de45b110bdf93cb2a74f7e5802855ec0d
    Image:          dockersamples/examplevotingapp_vote
    Image ID:       docker.io/dockersamples/examplevotingapp_vote@sha256:7102d3b952ec84e3541ee12e7217e320c52aed60b13501c3158f46376a907466
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 10 Sep 2025 15:59:53 +0530
    Ready:          True
    Restart Count:  0
    Environment:
      DD_TRACE_ENABLED:    true
      DD_AGENT_HOST:        (v1:status.hostIP)
      DD_SERVICE:          voting-app
      DD_ENV:              production
      DD_VERSION:          1.0.0
      DD_TRACE_AGENT_URL:  http://$(DD_AGENT_HOST):8126
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jmcqs (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-jmcqs:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>


Name:             worker-5c897b4865-m5d7x
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-agentpool-26539386-vmss000001/10.224.0.5
Start Time:       Wed, 10 Sep 2025 15:36:11 +0530
Labels:           app=worker
                  pod-template-hash=5c897b4865
Annotations:      <none>
Status:           Running
IP:               10.244.1.57
IPs:
  IP:           10.244.1.57
Controlled By:  ReplicaSet/worker-5c897b4865
Containers:
  worker:
    Container ID:   containerd://aa56ef0774a16edc887d16b9261ec6740267e1c56d00a73b77e7158b09917fd3
    Image:          dockersamples/examplevotingapp_worker
    Image ID:       docker.io/dockersamples/examplevotingapp_worker@sha256:c8a8571065479c12567e8e440836e543d185c678cd4781a32b100f71e8f39c86
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 10 Sep 2025 15:36:21 +0530
    Ready:          True
    Restart Count:  0
    Environment:
      DD_AGENT_HOST:        (v1:status.hostIP)
      DD_SERVICE:          worker-app
      DD_ENV:              production
      DD_VERSION:          1.0.0
      DD_TRACE_AGENT_URL:  http://$(DD_AGENT_HOST):8126
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-qmsrd (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-qmsrd:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>

```
---

## 4. Application Testing

### 4.1 Vote Application Access
- **URL**: http://4.144.223.92:8080
- **Function**: Cats vs Dogs voting interface

![alt text](image-10.png)


### 4.2 Result Application Access
- **URL**: http://20.212.142.66:8081
- **Function**: Real-time voting results display

![alt text](image-11.png)

### 4.3 Load Balancer Configuration

![alt text](image-12.png)

---

## 5. DataDog Integration

### 5.1 DataDog Agent Installation

#### Helm Installation Command
#### Helm install command execution*
```
helm repo add datadog https://helm.datadoghq.com
sudo snap install helm --classic
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
helm repo add datadog https://helm.datadoghq.com
helm repo update
```

```bash
helm install datadog-agent datadog/datadog \
  --create-namespace \
  --namespace datadog \
  --set datadog.apiKey= ***************** \
  --set datadog.site=datadoghq.com \
  --set datadog.apm.enabled=true \
  --set datadog.processAgent.enabled=true \
  --set datadog.logs.enabled=true \
  --set clusterAgent.enabled=true
```


### 5.2 DataDog Pods Status
```bash
kubectl get pods -n datadog
```
![alt text](image-13.png)

### 5.3 DataDog Agent Configuration
```bash
kubectl exec -n datadog -it <datadog-pod> -c agent -- agent status
```

### 5.4 APM Configuration Attempts

#### Environment Variables Added
```yaml
env:
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
- name: DD_SERVICE
  value: "voting-app"
- name: DD_ENV
  value: "production"
- name: DD_VERSION
  value: "1.0.0"
- name: DD_TRACE_AGENT_URL
  value: "http://$(DD_AGENT_HOST):8126"
```

---

## 6. DataDog Monitoring Views

### 6.1 Infrastructure Monitoring

#### Kubernetes Overview
![alt text](image-14.png)

#### Cluster Map View
![alt text](image-15.png)

#### Node Monitoring
Node1: aks-agentpool-26539386-vmss000000
![alt text](image-16.png)

Node2: ![alt text](image-18.png)
![alt text](image-17.png)

### 6.2 Container Monitoring

#### Container Overview
![alt text](image-19.png)

### 6.3 Process Monitoring

#### Process List
![alt text](image-20.png)

#### Process Details
![alt text](image-21.png)
Logs
![alt text](image-22.png)
Network
![alt text](image-23.png)
Related Processes
![alt text](image-24.png)
Related Resources
![alt text](image-25.png)

### 6.4 APM Monitoring

#### Service Map

![alt text](image-26.png)

#### APM Services
![alt text](image-32.png)
![alt text](image-27.png)
![alt text](image-28.png)


### 6.5 Log Management

#### Log Explorer

![alt text](image-29.png)

#### Application Logs
![alt text](image-30.png)

### 6.6 Host Map
![alt text](image-31.png)

---

## 7. Troubleshooting

### 7.1 Common Issues

#### DataDog Agent Issues
```bash
# Check agent status
kubectl logs -n datadog -l app=datadog-agent

# Verify connectivity
kubectl exec -n datadog -it <pod> -c agent -- agent status
```

---

## 8. Summary

### 8.1 What's Working ✅
- AKS cluster fully operational
- All application components deployed
- LoadBalancer services accessible
- DataDog infrastructure monitoring active
- Container and process monitoring enabled
- Log collection working

### 8.2 What's Limited ⚠️
- APM tracing requires application code changes
- Distributed tracing not available without tracing libraries
- Service dependency mapping limited

### 8.3 Next Steps
1. Implement tracing libraries in application images
2. Enable distributed tracing
3. Set up custom dashboards
4. Configure alerting rules
5. Implement log parsing and analysis

---

## 9. Commands Reference

### Kubernetes Commands
```bash
# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl get all

# Application management
kubectl get deployments
kubectl get services
kubectl get pods

# DataDog management
kubectl get pods -n datadog
kubectl logs -n datadog -l app=datadog-agent
```

### DataDog Commands
```bash
# Agent status
kubectl exec -n datadog -it <pod> -c agent -- agent status

# Check APM
kubectl exec -n datadog -it <pod> -c agent -- agent status | grep -A 10 "APM"

# Check processes
kubectl exec -n datadog -it <pod> -c agent -- agent status | grep -A 10 "Process"
```

---
