# Infrastructure Monitoring Process

## Overview

This guide demonstrates how to enable and configure process monitoring in DataDog for comprehensive infrastructure visibility.

## Process Monitoring Setup

### Default State
Process monitoring is **disabled by default** and needs to be enabled in the DataDog agent configuration file (datadog.yaml).

### Configuration Required
Add the following entry to enable process monitoring:

```yaml
process_config:
  enabled: "true"
```

## Before Enabling Process Monitoring

### Windows VM Status
![alt text](image.png)

### Linux VM Status
![alt text](image-3.png)
![alt text](image-1.png)

## Enabling Process Monitoring

### Windows VM Configuration
Modified the YAML file and restarted the DataDog agent:

![alt text](image-2.png)

### After Enabling - Results
![alt text](image-4.png)
![alt text](image-11.png)

## Process Explorer Interface

### Accessing Processes
Under **Infrastructure → Processes**, you can view all running processes:

![alt text](image-5.png)

### Visualization Options

#### 1. Time Series Graph
Shows process metrics over time:

![alt text](image-7.png)

#### 2. Scatter Plot
Displays process distribution and relationships:

![alt text](image-6.png)

## Process Management Features

### Process List Customization

**Default Process View:**
![alt text](image-8.png)

**After Customization** - Added PID and PPID columns:
![alt text](image-9.png)

### Process Details
Click on any process to get detailed information:

![alt text](image-10.png)

### Filtering Capabilities
Filter processes based on various criteria:

![alt text](image-12.png)

## Security Features

### Data Scrubbing Configuration
Protect sensitive information in process command-line arguments:

```yaml
scrub_args: true
custom_sensitive_words: ['type', 'user*']
```

**Configuration Options:**
- `scrub_args: true` → Automatically scrubs command-line arguments
- `custom_sensitive_words` → Define custom words/keys to redact

![alt text](image-13.png)

### Wildcard Usage Guidelines
![alt text](image-14.png)

## Process Metrics

### Available Metrics
DataDog provides comprehensive process metrics:

![alt text](image-15.png)

### Custom Metric Creation
Create custom metric tags for specific monitoring needs:

![alt text](image-16.png)

### Metric Explorer Integration
View newly created metrics in the Metric Explorer:

![alt text](image-17.png)

## Key Benefits

- **Complete Process Visibility**: Monitor all running processes across infrastructure
- **Resource Usage Tracking**: CPU, memory, and I/O metrics per process
- **Security**: Scrub sensitive data from process arguments
- **Customization**: Tailor views and metrics to specific needs
- **Historical Analysis**: Time-series data for trend analysis
- **Real-time Monitoring**: Live process status and performance

## Configuration Summary

1. **Enable Process Monitoring**: Add `process_config: enabled: "true"` to datadog.yaml
2. **Restart Agent**: Apply configuration changes
3. **Access Interface**: Navigate to Infrastructure → Processes
4. **Customize Views**: Add relevant columns (PID, PPID, etc.)
5. **Configure Security**: Enable data scrubbing for sensitive information
6. **Create Metrics**: Define custom metrics for specific monitoring requirements