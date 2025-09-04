# DataDog Setup - VM Monitoring

## Overview

This guide demonstrates setting up DataDog monitoring on Azure VMs with agent installation and configuration.

## VM Setup

### 1. Linux VM (Ubuntu)
**Hostname**: LinuxVM

![alt text](image-1.png)

### 2. Windows VM
**Hostname**: WindowsVM

![alt text](image.png)
![alt text](image-3.png)

## DataDog Agent Installation

Both VMs have DataDog Agent installed via VM Extensions:

![alt text](image-2.png)

## DataDog Prerequisites

Required setup and API key configuration:

![alt text](image-4.png)

## DataDog Dashboard

### Host Map View

The Host Map provides a visual overview of all monitored hosts:

![alt text](image-5.png)

### CPU Usage Monitoring

- **Green**: CPU usage below 50%
- **Orange**: CPU usage approaching 100%

![alt text](image-6.png)

### System Dashboard

Detailed system metrics for LinuxVM:

![alt text](image-7.png)

## Tags Configuration

Tags are used to filter and identify resources based on custom labels.

![alt text](image-8.png)

### Linux VM Tags

1. **Add tags to LinuxVM configuration**:

![alt text](image-9.png)

2. **Restart DataDog agent**:
```bash
sudo systemctl restart datadog-agent
```

3. **Updated tags in DataDog UI**:

![alt text](image-12.png)

### Windows VM Tags

1. **Add tags to WindowsVM and restart agent**:

![alt text](image-10.png)

2. **Updated tags in DataDog UI**:

![alt text](image-11.png)

## Key Features Demonstrated

- **Multi-platform Monitoring**: Both Linux and Windows VMs
- **Real-time Metrics**: CPU, memory, and system performance
- **Visual Host Map**: Easy identification of system health
- **Custom Tagging**: Resource organization and filtering
- **Automated Agent Installation**: VM extensions for easy deployment

## Benefits

- **Centralized Monitoring**: Single dashboard for all VMs
- **Performance Insights**: Real-time system metrics
- **Resource Organization**: Tag-based filtering and grouping
- **Proactive Monitoring**: Visual indicators for system health