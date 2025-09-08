# DataDog APM Setup Guide

## Prerequisites
- DataDog account with API key
- Flask weather application (weather_simple.py)
- Linux system (Ubuntu/Debian)

## Step 1: Install DataDog Agent

### 1.1 Download and Install Agent
```bash
# Download DataDog Agent installation script
DD_API_KEY=<YOUR_API_KEY> DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Alternative: Manual installation for Ubuntu/Debian
sudo apt-get update
sudo apt-get install apt-transport-https curl gnupg
curl -fsSL https://keys.datadoghq.com/DATADOG_APM_KEYS.public | sudo gpg --dearmor -o /usr/share/keyrings/datadog-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg] https://apt.datadoghq.com/ stable 7" | sudo tee /etc/apt/sources.list.d/datadog.list
sudo apt-get update
sudo apt-get install datadog-agent
```

### 1.2 Configure Agent
```bash
# Copy configuration template
sudo cp /etc/datadog-agent/datadog.yaml.example /etc/datadog-agent/datadog.yaml

# Edit configuration file
sudo nano /etc/datadog-agent/datadog.yaml
```

Add your API key to the configuration:
```yaml
api_key: YOUR_DATADOG_API_KEY
site: datadoghq.com

# Enable APM
apm_config:
  enabled: true
  
# Enable process monitoring
process_config:
  enabled: "true"
```

### 1.3 Start DataDog Agent
```bash
sudo systemctl start datadog-agent
sudo systemctl enable datadog-agent
sudo systemctl status datadog-agent
```

## Step 2: Install Python APM Dependencies

### 2.1 Create Clean Requirements File
```bash
cd /home/imranshaikh/Trainingplan/training_plan/6.DataDog/Day_14/11.APM/APM_1/
```

### 2.2 Install Required Packages
```bash
pip3 install ddtrace flask requests
```

## Step 3: Modify Flask Application for APM

### 3.1 Update weather_simple.py with DataDog Tracing

### 3.2 Add Environment Variables

### 3.3 Configure APM Settings

## Step 4: Run Application with APM

### 4.1 Set Environment Variables
```bash
export DD_SERVICE="weather-app"
export DD_ENV="development"
export DD_VERSION="1.0.0"
export DD_TRACE_AGENT_URL="http://localhost:8126"
```

### 4.2 Run with ddtrace
```bash
ddtrace-run python3 weather_simple.py
```

## Step 5: Verify APM Data in DataDog

### 5.1 Check APM Dashboard
- Navigate to APM → Services in DataDog UI
- Look for "weather-app" service
- Verify traces are being collected

### 5.2 Monitor Key Metrics
- Request rate
- Error rate
- Response time (latency)
- Throughput

## Step 6: Advanced APM Configuration

### 6.1 Custom Instrumentation
### 6.2 Error Tracking
### 6.3 Performance Monitoring
### 6.4 Database Query Monitoring

## Troubleshooting

### Common Issues:
1. Agent not running
2. Incorrect API key
3. Network connectivity issues
4. Python package conflicts

### Debug Commands:
```bash
sudo datadog-agent status
sudo datadog-agent check apm
tail -f /var/log/datadog/agent.log
```