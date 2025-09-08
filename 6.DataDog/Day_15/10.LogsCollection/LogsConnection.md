# DataDog Logs Collection Configuration

## Overview
This guide shows how to configure DataDog Agent to collect logs from Python applications and send them to DataDog for monitoring and analysis.

## Configuration Setup

### 1. DataDog Agent Configuration

**File:** `/etc/datadog-agent/conf.d/python_logs.d/conf.yaml`

```yaml
init_config:

instances:

## Log section
logs:
  - type: file
    path: "/var/log/datadog/python_app.log"
    service: python-web-app
    source: python
    sourcecategory: application
    tags:
      - env:production
      - team:backend
      - app:selenium-scraper
    # For multiline logs with date format yyyy-mm-dd
    log_processing_rules:
      - type: multi_line
        name: new_log_start_with_date
        pattern: \d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])
```

### 2. Enable Logs Collection

**File:** `/etc/datadog-agent/datadog.yaml`

```yaml
# Enable log collection
logs_enabled: true

# Optional: Set log level
log_level: INFO
```

### 3. Restart DataDog Agent

```bash
sudo systemctl restart datadog-agent
sudo systemctl status datadog-agent
```

## Python Application Code

### Basic Python App with Logging

**File:** `python_app_basic.py`

```python
if __name__ == '__main__':
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    import undetected_chromedriver as uc
    import logging
    from pythonjsonlogger import jsonlogger 
    
    options = uc.ChromeOptions()
    options.add_argument("--incognito")
    driver = uc.Chrome(executable_path="chromedriver.exe", options=options)
    driver.maximize_window()
    
    # Logging configuration
    logger = logging.getLogger()
    
    logHandler = logging.FileHandler(filename='/var/log/datadog/python_app.log')
    formatter = jsonlogger.JsonFormatter()
    logHandler.setFormatter(formatter)
    logger.addHandler(logHandler)
    logger.setLevel(logging.INFO)
    
    try:
        driver.get("https://www.amazon.com/")
        driver.find_element(By.XPATH, value="//div[contains(@class,'product')]")
        logger.info('Product found successfully', extra={'referral_code': '79vn4et', 'status': 'success'})
        
    except Exception as e:
        logger.error('Product not found in website', extra={
            'referral_code': '79vn4et', 
            'error': str(e),
            'status': 'failed',
            'url': 'https://www.amazon.com/'
        })
    
    driver.quit()
```

### Python App with Continuous Logging

**File:** `python_app_loop.py`

```python
if __name__ == '__main__':
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    import undetected_chromedriver as uc
    import logging
    from pythonjsonlogger import jsonlogger 
    import itertools
    from time import sleep
    import datetime
    
    options = uc.ChromeOptions()
    options.add_argument("--incognito")
    driver = uc.Chrome(executable_path="chromedriver.exe", options=options)
    driver.maximize_window()
    
    # Logging configuration
    logger = logging.getLogger()
    
    logHandler = logging.FileHandler(filename='/var/log/datadog/python_app.log')
    formatter = jsonlogger.JsonFormatter()
    logHandler.setFormatter(formatter)
    logger.addHandler(logHandler)
    logger.setLevel(logging.INFO)
    
    try:
        driver.get("https://www.amazon.com/")
        driver.find_element(By.XPATH, value="//div[contains(@class,'product')]")
        logger.info('Product found successfully', extra={'referral_code': '79vn4et', 'status': 'success'})
        
    except Exception as e:
        logger.error('Starting continuous monitoring due to product not found', extra={
            'referral_code': '79vn4et', 
            'error': str(e),
            'status': 'monitoring_started'
        })
        
        count = 0
        for x in itertools.repeat(1): 
            count += 1
            logger.info('Product monitoring attempt', extra={
                'referral_code': '79vn4et',
                'attempt': count,
                'timestamp': datetime.datetime.now().isoformat(),
                'status': 'monitoring'
            })
            sleep(5)  # Changed to 5 seconds to avoid spam
            
            # Break after 10 attempts for demo
            if count >= 10:
                logger.info('Monitoring completed', extra={
                    'referral_code': '79vn4et',
                    'total_attempts': count,
                    'status': 'completed'
                })
                break
    
    driver.quit()
```

## Setup Instructions

### 1. Create Log Directory

```bash
sudo mkdir -p /var/log/datadog
sudo chown dd-agent:dd-agent /var/log/datadog
sudo chmod 755 /var/log/datadog
```

### 2. Install Python Dependencies

```bash
pip3 install selenium undetected-chromedriver python-json-logger
```

### 3. Create DataDog Configuration

```bash
sudo mkdir -p /etc/datadog-agent/conf.d/python_logs.d
sudo tee /etc/datadog-agent/conf.d/python_logs.d/conf.yaml > /dev/null << 'EOF'
init_config:

instances:

logs:
  - type: file
    path: "/var/log/datadog/python_app.log"
    service: python-web-app
    source: python
    sourcecategory: application
    tags:
      - env:production
      - team:backend
      - app:selenium-scraper
EOF
```

### 4. Enable Logs in DataDog Agent

```bash
sudo sed -i 's/# logs_enabled: false/logs_enabled: true/' /etc/datadog-agent/datadog.yaml
sudo systemctl restart datadog-agent
```

### 5. Run Python Applications

```bash
# Run basic app
python3 python_app_basic.py

# Run continuous logging app
python3 python_app_loop.py
```

## Verification

### 1. Check Log File

```bash
# View generated logs
tail -f /var/log/datadog/python_app.log

# Check log format
cat /var/log/datadog/python_app.log | jq .
```

### 2. Verify DataDog Agent

```bash
# Check agent status
sudo datadog-agent status

# Check logs integration
sudo datadog-agent check logs_agent
```

### 3. DataDog UI Verification

1. Go to **Logs** in DataDog UI
2. Search for `service:python-web-app`
3. Filter by `source:python`
4. Look for your application logs

## Log Analysis Queries

### Basic Queries

```
# All Python app logs
service:python-web-app

# Error logs only
service:python-web-app status:failed

# Logs with referral code
service:python-web-app @referral_code:79vn4et

# Monitoring attempts
service:python-web-app @status:monitoring
```

### Advanced Queries

```
# Count errors by hour
service:python-web-app status:failed | timeseries count by status

# Monitor attempt frequency
service:python-web-app @status:monitoring | timeseries count by attempt

# Error rate calculation
service:python-web-app | timeseries count by status
```

## Troubleshooting

### Common Issues

1. **Logs not appearing in DataDog:**
```bash
# Check file permissions
ls -la /var/log/datadog/python_app.log

# Check agent logs
sudo tail -f /var/log/datadog/agent.log | grep -i logs
```

2. **Permission denied:**
```bash
sudo chown dd-agent:dd-agent /var/log/datadog/python_app.log
sudo chmod 644 /var/log/datadog/python_app.log
```

3. **Agent not collecting logs:**
```bash
# Verify logs_enabled
sudo grep logs_enabled /etc/datadog-agent/datadog.yaml

# Check configuration
sudo datadog-agent configcheck
```

### Debug Commands

```bash
# Test log collection
echo '{"message": "test log", "level": "info"}' >> /var/log/datadog/python_app.log

# Check agent logs processing
sudo datadog-agent logs-agent status

# Validate configuration
sudo datadog-agent check logs_agent -v
```

This configuration will collect logs from your Python applications and send them to DataDog for monitoring and analysis.