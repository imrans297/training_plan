# DataDog APM (Application Performance Monitoring) Complete Setup Guide

## Overview
This document provides a comprehensive step-by-step guide for implementing DataDog APM with a Flask weather application, from initial setup to advanced monitoring.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [DataDog Agent Installation](#datadog-agent-installation)
3. [Flask Application APM Integration](#flask-application-apm-integration)
4. [Configuration Files](#configuration-files)
5. [Running the Application](#running-the-application)
6. [Monitoring and Verification](#monitoring-and-verification)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Configuration](#advanced-configuration)

## Prerequisites

### Required Components
- **DataDog Account**: Sign up at [datadoghq.com](https://datadoghq.com)
- **API Key**: Obtain from DataDog dashboard
- **Linux System**: Ubuntu/Debian (tested)
- **Python 3.7+**: With pip installed
- **Flask Application**: Weather app (provided)

### System Requirements
- **RAM**: Minimum 512MB available
- **CPU**: 1 core minimum
- **Network**: Internet connectivity for API calls
- **Ports**: 8000 (Flask app), 8126 (DataDog APM agent)

## DataDog Agent Installation

### Step 1: Automated Installation Script

We've created an automated installation script for easy setup:

```bash
# Make the installation script executable
chmod +x install_datadog_agent.sh

# Run the installation script
./install_datadog_agent.sh
```

### Step 2: Manual Installation (Alternative)

If you prefer manual installation:

```bash
# Update system packages
sudo apt-get update
sudo apt-get install -y apt-transport-https curl gnupg

# Add DataDog GPG key
curl -fsSL https://keys.datadoghq.com/DATADOG_APM_KEYS.public | sudo gpg --dearmor -o /usr/share/keyrings/datadog-archive-keyring.gpg

# Add DataDog repository
echo "deb [signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg] https://apt.datadoghq.com/ stable 7" | sudo tee /etc/apt/sources.list.d/datadog.list

# Install DataDog agent
sudo apt-get update
sudo apt-get install -y datadog-agent
```

### Step 3: Agent Configuration

Configure the DataDog agent with your API key:

```bash
# Copy the provided configuration
sudo cp datadog.yaml /etc/datadog-agent/datadog.yaml

# Edit with your API key
sudo nano /etc/datadog-agent/datadog.yaml
```

Replace `YOUR_DATADOG_API_KEY` with your actual API key.

### Step 4: Start DataDog Agent

```bash
# Start and enable the agent
sudo systemctl start datadog-agent
sudo systemctl enable datadog-agent

# Verify agent status
sudo systemctl status datadog-agent
sudo datadog-agent status
```

## Flask Application APM Integration

### Application Structure

After setup, your directory structure will be:

```
11.APM/APM_1/
├── weather_simple.py          # Original Flask app
├── weather_apm.py            # APM-instrumented version
├── requirements_clean.txt    # Clean dependencies
├── datadog.yaml             # Agent configuration
├── setup_apm.sh            # Application startup script
├── install_datadog_agent.sh # Agent installation script
└── templates/
    └── index.html          # HTML template
```

### Key APM Features Implemented

#### 1. Automatic Instrumentation
```python
from ddtrace import tracer, patch_all
from ddtrace.contrib.flask import TraceMiddleware

# Initialize DataDog tracing
patch_all()
```

#### 2. Custom Spans and Tags
```python
def get_weather_details(city):
    with tracer.trace("weather.api_call") as span:
        span.set_tag("city", city)
        # API call logic
        span.set_tag("success", True)
```

#### 3. Error Tracking
```python
try:
    # API call
except Exception as e:
    span.set_tag("error", True)
    span.set_tag("error.message", str(e))
```

#### 4. Performance Monitoring
- **Request tracing**: Every HTTP request is traced
- **Database queries**: Automatic SQL query monitoring
- **External API calls**: OpenWeatherMap API monitoring
- **Custom metrics**: Temperature conversion timing

## Configuration Files

### 1. requirements_clean.txt
```
Flask==2.3.3
ddtrace==2.3.0
requests==2.31.0
```

### 2. DataDog Agent Configuration (datadog.yaml)
Key settings for APM:
```yaml
api_key: YOUR_DATADOG_API_KEY
site: datadoghq.com

apm_config:
  enabled: true
  receiver_port: 8126
  analyzed_rate_by_service:
    weather-app: 1.0
```

### 3. Environment Variables
```bash
export DD_SERVICE="weather-app"
export DD_ENV="development"
export DD_VERSION="1.0.0"
export DD_TRACE_AGENT_URL="http://localhost:8126"
```

## Running the Application

### Method 1: Automated Setup (Recommended)

```bash
# Make setup script executable
chmod +x setup_apm.sh

# Run the application with APM
./setup_apm.sh
```

### Method 2: Manual Setup

```bash
# Install dependencies
pip3 install -r requirements_clean.txt

# Set environment variables
export DD_SERVICE="weather-app"
export DD_ENV="development"
export DD_VERSION="1.0.0"

# Run with ddtrace
ddtrace-run python3 weather_apm.py
```

### Application Endpoints

- **Main Application**: `http://localhost:8000`
- **Health Check**: `http://localhost:8000/health`
- **Default City**: Delhi (if no city specified)

## Monitoring and Verification

### 1. DataDog APM Dashboard

Access your APM data at: `https://app.datadoghq.com/apm/services`

**Key Metrics to Monitor:**
- **Request Rate**: Requests per second
- **Error Rate**: Percentage of failed requests
- **Latency**: Response time percentiles (p50, p95, p99)
- **Throughput**: Total requests processed

### 2. Service Map

View service dependencies and performance:
- Weather App → OpenWeatherMap API
- Request flow visualization
- Error propagation tracking

### 3. Trace Analysis

**Trace Components:**
- `weather.request_handler`: Main request processing
- `weather.api_call`: External API interaction
- `weather.http_request`: HTTP request timing
- `temperature.conversion`: Temperature calculation

### 4. Custom Tags Available

- `city`: Requested city name
- `request.method`: HTTP method (GET/POST)
- `weather.country`: Country code from API
- `weather.temperature_celsius`: Converted temperature
- `success`: Operation success status
- `error`: Error occurrence flag

## Troubleshooting

### Common Issues and Solutions

#### 1. Agent Not Running
**Symptoms:**
- No traces in DataDog dashboard
- Connection refused errors

**Solutions:**
```bash
# Check agent status
sudo systemctl status datadog-agent

# Restart agent
sudo systemctl restart datadog-agent

# Check logs
sudo tail -f /var/log/datadog/agent.log
```

#### 2. APM Port Not Accessible
**Symptoms:**
- ddtrace connection errors
- Port 8126 not responding

**Solutions:**
```bash
# Test APM endpoint
curl http://localhost:8126/info

# Check port binding
sudo netstat -tlnp | grep 8126

# Verify agent configuration
sudo datadog-agent check apm
```

#### 3. Missing Traces
**Symptoms:**
- Application runs but no traces appear
- Partial trace data

**Solutions:**
```bash
# Verify environment variables
echo $DD_SERVICE
echo $DD_ENV

# Check trace sampling rate
export DD_TRACE_SAMPLE_RATE="1.0"

# Enable debug logging
export DD_TRACE_DEBUG="true"
```

#### 4. Python Package Conflicts
**Symptoms:**
- Import errors
- Version compatibility issues

**Solutions:**
```bash
# Create clean virtual environment
python3 -m venv apm_env
source apm_env/bin/activate
pip install -r requirements_clean.txt
```

### Debug Commands

```bash
# Agent status and configuration
sudo datadog-agent status
sudo datadog-agent check apm
sudo datadog-agent configcheck

# Log monitoring
sudo tail -f /var/log/datadog/agent.log
sudo tail -f /var/log/datadog/trace-agent.log

# Network connectivity
curl -v http://localhost:8126/info
telnet localhost 8126

# Process monitoring
ps aux | grep datadog
ps aux | grep python
```

## Advanced Configuration

### 1. Custom Metrics

Add custom business metrics:

```python
from datadog import statsd

# Increment counter
statsd.increment('weather.requests', tags=['city:' + city])

# Record timing
with statsd.timed('weather.api_response_time'):
    # API call
```

### 2. Distributed Tracing

For microservices architecture:

```python
# Propagate trace context
headers = {}
tracer.inject(span.context, Format.HTTP_HEADERS, headers)

# Make request with trace context
response = requests.get(url, headers=headers)
```

### 3. Sampling Configuration

```python
# Configure sampling rates
from ddtrace.sampler import RateSampler

tracer.configure(
    settings={
        'FILTERS': [
            FilterRequestsOnUrl(r'http://testserver/health')
        ],
        'PRIORITY_SAMPLING': True,
    }
)
```

### 4. Performance Optimization

```yaml
# datadog.yaml optimizations
apm_config:
  max_traces_per_second: 100
  max_memory: 512  # MB
  max_cpu_percent: 50
  
  # Reduce overhead
  analyzed_rate_by_service:
    weather-app: 0.1  # Sample 10% of traces
```

## Monitoring Best Practices

### 1. Alert Configuration

Set up alerts for:
- **High Error Rate**: > 5% errors
- **High Latency**: p95 > 2 seconds
- **Low Throughput**: < 10 requests/minute
- **Service Availability**: Health check failures

### 2. Dashboard Creation

Create custom dashboards with:
- **Service Overview**: Key metrics summary
- **Error Analysis**: Error rates and types
- **Performance Trends**: Latency over time
- **Business Metrics**: Weather requests by city

### 3. SLA Monitoring

Define and monitor:
- **Availability**: 99.9% uptime
- **Response Time**: < 1 second p95
- **Error Rate**: < 1% of requests

## Security Considerations

### 1. API Key Management
- Store API keys securely
- Use environment variables
- Rotate keys regularly
- Restrict key permissions

### 2. Network Security
- Firewall configuration for port 8126
- TLS encryption for agent communication
- VPC/subnet isolation

### 3. Data Privacy
- Avoid logging sensitive data
- Configure data scrubbing
- Implement data retention policies

## Performance Impact

### APM Overhead
- **CPU**: < 5% additional usage
- **Memory**: ~50MB for agent
- **Network**: Minimal trace data transmission
- **Latency**: < 1ms per request

### Optimization Tips
- Use sampling for high-traffic applications
- Configure appropriate trace retention
- Monitor agent resource usage
- Tune collection intervals

## Step-by-Step Execution Guide

### Complete Setup Process

1. **Install DataDog Agent**
   ```bash
   chmod +x install_datadog_agent.sh
   ./install_datadog_agent.sh
   ```

2. **Configure Agent**
   - Edit `/etc/datadog-agent/datadog.yaml`
   - Add your API key
   - Enable APM configuration

3. **Install Python Dependencies**
   ```bash
   pip3 install -r requirements_clean.txt
   ```

4. **Run APM-Enabled Application**
   ```bash
   chmod +x setup_apm.sh
   ./setup_apm.sh
   ```

5. **Verify Setup**
   - Check agent status: `sudo datadog-agent status`
   - Test application: `curl http://localhost:8000`
   - View traces: DataDog APM dashboard

### File Modifications Required

1. **Create weather_apm.py** (APM-instrumented version)
2. **Update requirements.txt** (add ddtrace dependency)
3. **Configure datadog.yaml** (agent settings)
4. **Set environment variables** (service identification)

## Current Status

✅ **DataDog Agent Installation Script Created**
✅ **Flask Application with APM Instrumentation**
✅ **Custom Tracing and Error Tracking**
✅ **Performance Monitoring Setup**
✅ **Health Check Endpoint**
✅ **Automated Setup Scripts**
✅ **Comprehensive Documentation**
✅ **Troubleshooting Guide**

## Next Steps

1. **Production Deployment**
   - Configure production environment
   - Set up load balancing
   - Implement CI/CD integration

2. **Advanced Monitoring**
   - Create custom dashboards
   - Set up alerting rules
   - Implement SLA monitoring

3. **Scaling Considerations**
   - Multi-instance deployment
   - Database connection pooling
   - Caching implementation

4. **Integration Expansion**
   - Log correlation
   - Infrastructure monitoring
   - Synthetic testing

The weather application is now fully instrumented with DataDog APM and ready for production monitoring!