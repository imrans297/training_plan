# DataDog AKS Integration - Complete Setup Guide

## Project Overview

This guide documents the complete setup of DataDog monitoring for an AKS (Azure Kubernetes Service) cluster running a cats vs dogs voting application.

### What We Accomplished
- ✅ DataDog Agent installed on AKS cluster
- ✅ Process monitoring enabled (117+ processes tracked)
- ✅ Container monitoring active (31+ containers monitored)
- ✅ Infrastructure monitoring working
- ✅ Kubernetes integration complete
- ⚠️ APM tracing attempted (limited success due to application constraints)

## Environment Details

### AKS Cluster Information
- **Cluster Name**: Voting-app
- **Resource Group**: VotingApp
- **Nodes**: 2 worker nodes
- **Location**: Azure region
- **DataDog API Key**: ******************

### Application Stack
- **Vote App**: Python Flask (Cats vs Dogs voting interface)
- **Result App**: Node.js (Results display)
- **Worker App**: .NET (Vote processing)
- **Database**: PostgreSQL
- **Cache**: Redis

### External Access
- **Vote App**: http://4.144.223.92:8080
- **Result App**: http://20.212.142.66:8081

## Installation Steps

### Step 1: DataDog Agent Installation via Helm

```bash
# Connect to AKS cluster
az aks get-credentials --resource-group VotingApp --name Voting-app

# Install Helm (if not already installed)
sudo snap install helm --classic

# Add DataDog Helm repository
helm repo add datadog https://helm.datadoghq.com
helm repo update

# Install DataDog Agent with monitoring features
helm install datadog-agent datadog/datadog \
  --create-namespace \
  --namespace datadog \
  --set datadog.apiKey=********** \
  --set datadog.site=datadoghq.com \
  --set datadog.apm.enabled=true \
  --set datadog.processAgent.enabled=true \
  --set datadog.logs.enabled=true \
  --set clusterAgent.enabled=true
```

### Step 2: Verify Installation

```bash
# Check DataDog pods are running
kubectl get pods -n datadog

# Expected output:
# NAME                                          READY   STATUS    RESTARTS   AGE
# datadog-agent-8kp7q                           2/2     Running   0          66s
# datadog-agent-cluster-agent-6c4b4868c-k5qlw   1/1     Running   0          66s
# datadog-agent-p6g6w                           2/2     Running   0          35s

# Check agent status
kubectl exec -n datadog -it $(kubectl get pods -n datadog -l app=datadog-agent -o jsonpath='{.items[0].metadata.name}') -c agent -- agent status
```

### Step 3: Application Deployment

The voting application was deployed using Kubernetes manifests:

```bash
# Application structure
kubectl get all

# Expected services:
# service/vote         LoadBalancer   10.0.192.77   4.144.223.92    8080:31000/TCP
# service/result       LoadBalancer   10.0.45.22    20.212.142.66   8081:31001/TCP
# service/db           ClusterIP      10.0.94.230   <none>          5432/TCP
# service/redis        ClusterIP      10.0.230.47   <none>          6379/TCP
```

## APM Integration Attempts

### Approach 1: Environment Variables Only

Added DataDog environment variables to application deployments:

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

**Result**: Environment variables set correctly but no traces generated (tracing libraries not installed in containers).

### Approach 2: Automatic Instrumentation

Attempted DataDog's automatic instrumentation:

```bash
# Enable automatic instrumentation
kubectl label namespace default admission.datadoghq.com/enabled=true

# Add instrumentation annotations
kubectl patch deployment vote -p '{"spec":{"template":{"metadata":{"annotations":{"admission.datadoghq.com/python-lib.version":"latest"}}}}}'
kubectl patch deployment result -p '{"spec":{"template":{"metadata":{"annotations":{"admission.datadoghq.com/js-lib.version":"latest"}}}}}'
```

**Result**: Admission controller had webhook configuration issues.

### Approach 3: Runtime Library Installation

Attempted to install tracing libraries at runtime:

```bash
# Install ddtrace in Python container
kubectl exec -it vote-pod -- pip install ddtrace

# Install dd-trace in Node.js container  
kubectl exec -it result-pod -- npm install dd-trace
```

**Result**: Libraries installed successfully but lost on pod restart.

### Approach 4: Command Override

Modified deployment commands to use tracing:

```bash
# Python Flask with ddtrace-run
kubectl patch deployment vote -p '{"spec":{"template":{"spec":{"containers":[{"name":"vote","command":["ddtrace-run","python","app.py"]}]}}}}'

# Node.js with dd-trace preload
kubectl patch deployment result -p '{"spec":{"template":{"spec":{"containers":[{"name":"result","command":["node","-r","dd-trace/init","server.js"]}]}}}}'
```

**Result**: Pods crashed because tracing libraries weren't installed in the base images.

## Current Monitoring Status

### What's Working ✅

#### Infrastructure Monitoring
- **Kubernetes cluster**: Full visibility of AKS cluster
- **Nodes**: 2 worker nodes monitored
- **Pods**: All application pods tracked
- **Containers**: 31+ containers monitored
- **Processes**: 117+ processes tracked

#### Process Monitoring
```bash
# Verify process monitoring
kubectl exec -n datadog -it $(kubectl get pods -n datadog -l app=datadog-agent -o jsonpath='{.items[0].metadata.name}') -c agent -- agent status | grep -A 10 "Process Agent"

# Output shows:
# Process Component: Enabled Checks: [process rtprocess]
# Last collection time: 2025-09-10 10:30:13
# Number of processes: 117
# Number of containers: 31
```

#### APM Agent Status
```bash
# APM agent is running and ready
kubectl exec -n datadog -it datadog-agent-pod -c agent -- agent status | grep -A 10 "APM Agent"

# Output:
# APM Agent
# Status: Running
# Receiver: 0.0.0.0:8126
# Endpoints: https://trace.agent.datadoghq.com
```

### What's Limited ⚠️

#### APM Tracing
- **Issue**: Applications don't have built-in tracing libraries
- **Impact**: No distributed traces, service maps limited
- **Workaround**: Infrastructure and process monitoring provides comprehensive visibility

## DataDog Dashboard Navigation

### Infrastructure Monitoring
1. **Infrastructure → Kubernetes**
   - View: Voting-app cluster
   - Nodes: 2 AKS worker nodes
   - Pods: vote, result, worker, db, redis, datadog agents

2. **Infrastructure → Containers**
   - View: All 31+ containers
   - Metrics: CPU, memory, network usage
   - Status: Running containers and their health

3. **Infrastructure → Processes**
   - View: All 117+ processes
   - Filter: By container, node, or application
   - Metrics: CPU, memory usage per process

4. **Infrastructure → Host Map**
   - View: Visual representation of nodes
   - Metrics: Resource utilization
   - Health: Node status and performance

### Limited APM Views
1. **APM → Service Map**
   - Current: Minimal service discovery
   - Expected: Basic network topology without detailed traces

2. **APM → Services**
   - Current: Limited service detection
   - Potential: Some HTTP endpoint discovery

## Traffic Generation for Testing

### Generate Application Traffic
```bash
# Continuous traffic generation
for i in {1..50}; do 
  # Vote for cats
  curl -X POST -d "vote=a" http://4.144.223.92:8080 >/dev/null 2>&1
  
  # Vote for dogs  
  curl -X POST -d "vote=b" http://4.144.223.92:8080 >/dev/null 2>&1
  
  # Check results
  curl http://20.212.142.66:8081 >/dev/null 2>&1
  
  sleep 2
done
```

### Verify Traffic Impact
```bash
# Check if traces are being received
kubectl logs -n datadog -l app=datadog-agent -c trace-agent | tail -10

# Current output: "No data received" (expected without tracing libraries)
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. DataDog Agent Not Starting
```bash
# Check pod status
kubectl get pods -n datadog

# Check logs
kubectl logs -n datadog -l app=datadog-agent

# Common fixes:
# - Verify API key is correct
# - Check network connectivity
# - Ensure sufficient resources
```

#### 2. Process Monitoring Not Working
```bash
# Verify process agent configuration
kubectl exec -n datadog -it datadog-agent-pod -c agent -- agent status | grep -A 10 "Process"

# If not working, upgrade with process monitoring enabled:
helm upgrade datadog-agent datadog/datadog \
  --namespace datadog \
  --reuse-values \
  --set datadog.processAgent.enabled=true \
  --set datadog.processAgent.processCollection=true
```

#### 3. APM Traces Not Appearing
```bash
# Check APM agent status
kubectl exec -n datadog -it datadog-agent-pod -c agent -- agent status | grep -A 10 "APM"

# Verify trace agent logs
kubectl logs -n datadog -l app=datadog-agent -c trace-agent

# Root cause: Applications need tracing libraries installed
# Solution: Rebuild images with tracing libraries or use init containers
```

#### 4. Container Monitoring Issues
```bash
# Check container runtime access
kubectl exec -n datadog -it datadog-agent-pod -c agent -- ls -la /var/run/docker.sock

# Verify container metrics
kubectl exec -n datadog -it datadog-agent-pod -c agent -- agent status | grep -A 5 "Collector"
```

### Network Connectivity Issues
```bash
# Test DataDog endpoint connectivity
kubectl exec -n datadog -it datadog-agent-pod -c agent -- curl -I https://api.datadoghq.com

# Check DNS resolution
kubectl exec -n datadog -it datadog-agent-pod -c agent -- nslookup api.datadoghq.com
```

## Enhancement Options

### Option 1: Enable Universal Service Monitoring
```bash
# Enable USM for service discovery without code changes
helm upgrade datadog-agent datadog/datadog \
  --namespace datadog \
  --reuse-values \
  --set datadog.serviceMonitoring.enabled=true \
  --set datadog.networkMonitoring.enabled=true
```

### Option 2: Custom Application Images
Build new container images with tracing libraries:

```dockerfile
# For Python Flask (vote app)
FROM dockersamples/examplevotingapp_vote
RUN pip install ddtrace
ENV DD_TRACE_ENABLED=true
CMD ["ddtrace-run", "python", "app.py"]

# For Node.js (result app)
FROM dockersamples/examplevotingapp_result
RUN npm install dd-trace
ENV DD_TRACE_ENABLED=true
CMD ["node", "-r", "dd-trace/init", "server.js"]
```

### Option 3: Init Container Approach
Add init containers to install tracing libraries:

```yaml
initContainers:
- name: install-ddtrace
  image: python:3.11
  command: ['pip', 'install', 'ddtrace', '--target', '/shared/packages']
  volumeMounts:
  - name: shared-packages
    mountPath: /shared/packages
```

## Monitoring Metrics Available

### Infrastructure Metrics
- `kubernetes.cpu.usage` - CPU usage per pod/node
- `kubernetes.memory.usage` - Memory usage per pod/node
- `kubernetes.pods.running` - Number of running pods
- `container.cpu.usage` - Container-level CPU metrics
- `container.memory.usage` - Container-level memory metrics

### Process Metrics
- `system.processes.number` - Number of processes
- `process.cpu.usage` - Per-process CPU usage
- `process.memory.usage` - Per-process memory usage

### Network Metrics (if enabled)
- `network.bytes_sent` - Network traffic sent
- `network.bytes_received` - Network traffic received

## Alert Recommendations

### Critical Alerts
```bash
# High CPU usage
avg(last_5m):avg:kubernetes.cpu.usage{cluster_name:voting-app} > 80

# High memory usage  
avg(last_5m):avg:kubernetes.memory.usage{cluster_name:voting-app} > 85

# Pod crash detection
sum(last_5m):kubernetes.pods.running{cluster_name:voting-app} < 5
```

### Warning Alerts
```bash
# Moderate resource usage
avg(last_10m):avg:kubernetes.cpu.usage{cluster_name:voting-app} > 60

# DataDog agent health
avg(last_5m):kubernetes.pods.running{app:datadog-agent} < 2
```

## Files Created During Setup

### APM-Instrumented Deployments
- `/home/imranshaikh/Trainingplan/Kodecloud/example-voting-app/k8s-specifications/vote-deployment-apm.yaml`
- `/home/imranshaikh/Trainingplan/Kodecloud/example-voting-app/k8s-specifications/result-deployment-apm.yaml`
- `/home/imranshaikh/Trainingplan/Kodecloud/example-voting-app/k8s-specifications/worker-deployment-apm.yaml`

### Configuration Files
- DataDog agent configuration via Helm values
- Kubernetes manifests with DataDog environment variables

## Summary

### Successfully Implemented ✅
1. **DataDog Agent**: Fully operational on AKS cluster
2. **Infrastructure Monitoring**: Complete visibility of cluster, nodes, pods
3. **Process Monitoring**: 117+ processes tracked across all containers
4. **Container Monitoring**: 31+ containers monitored with resource metrics
5. **Kubernetes Integration**: Full cluster observability
6. **Application Access**: External LoadBalancer services working

### Partially Implemented ⚠️
1. **APM Tracing**: Environment variables configured but no traces due to missing libraries
2. **Service Discovery**: Limited without full APM instrumentation
3. **Distributed Tracing**: Not available without application-level tracing

### Next Steps for Full APM 🎯
1. **Rebuild Application Images**: Include tracing libraries in container images
2. **Use Init Containers**: Install tracing libraries at runtime
3. **Enable Universal Service Monitoring**: For service discovery without code changes
4. **Custom Instrumentation**: Add manual tracing to application code

The current setup provides comprehensive infrastructure and process monitoring, which is valuable for operations, performance monitoring, and troubleshooting even without full APM tracing capabilities.
