#!/bin/bash

# DataDog Agent Installation Script

echo "🔧 Installing DataDog Agent..."

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root for security reasons"
   echo "   Run without sudo, it will prompt for password when needed"
   exit 1
fi

# Prompt for API key
read -p "Enter your DataDog API Key: " DD_API_KEY

if [ -z "$DD_API_KEY" ]; then
    echo "❌ API Key is required"
    exit 1
fi

# Step 1: Update system packages
echo "📦 Updating system packages..."
sudo apt-get update

# Step 2: Install required dependencies
echo "📦 Installing dependencies..."
sudo apt-get install -y apt-transport-https curl gnupg

# Step 3: Add DataDog GPG key
echo "🔑 Adding DataDog GPG key..."
curl -fsSL https://keys.datadoghq.com/DATADOG_APM_KEYS.public | sudo gpg --dearmor -o /usr/share/keyrings/datadog-archive-keyring.gpg

# Step 4: Add DataDog repository
echo "📋 Adding DataDog repository..."
echo "deb [signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg] https://apt.datadoghq.com/ stable 7" | sudo tee /etc/apt/sources.list.d/datadog.list

# Step 5: Update package list
echo "🔄 Updating package list..."
sudo apt-get update

# Step 6: Install DataDog agent
echo "⬇️ Installing DataDog agent..."
sudo apt-get install -y datadog-agent

# Step 7: Configure the agent
echo "⚙️ Configuring DataDog agent..."

# Backup original config if it exists
if [ -f /etc/datadog-agent/datadog.yaml ]; then
    sudo cp /etc/datadog-agent/datadog.yaml /etc/datadog-agent/datadog.yaml.backup
fi

# Create configuration
sudo tee /etc/datadog-agent/datadog.yaml > /dev/null <<EOF
# DataDog Agent Configuration
api_key: $DD_API_KEY
site: datadoghq.com

# Hostname (optional)
# hostname: $(hostname)

# Tags
tags:
  - env:development
  - team:devops
  - application:weather-app

# APM Configuration
apm_config:
  enabled: true
  receiver_port: 8126
  analyzed_rate_by_service:
    weather-app: 1.0
  max_traces_per_second: 10

# Process monitoring
process_config:
  enabled: "true"

# Log collection
logs_enabled: true

# Network monitoring
network_config:
  enabled: true
EOF

# Step 8: Set proper permissions
echo "🔒 Setting permissions..."
sudo chown dd-agent:dd-agent /etc/datadog-agent/datadog.yaml
sudo chmod 640 /etc/datadog-agent/datadog.yaml

# Step 9: Start and enable the agent
echo "🚀 Starting DataDog agent..."
sudo systemctl start datadog-agent
sudo systemctl enable datadog-agent

# Step 10: Wait for agent to start
echo "⏳ Waiting for agent to start..."
sleep 10

# Step 11: Check agent status
echo "🔍 Checking agent status..."
sudo datadog-agent status

# Step 12: Verify APM is working
echo "🧪 Testing APM endpoint..."
curl -s http://localhost:8126/info

echo ""
echo "✅ DataDog Agent installation completed!"
echo ""
echo "📊 Next steps:"
echo "1. Verify agent status: sudo systemctl status datadog-agent"
echo "2. Check agent logs: sudo tail -f /var/log/datadog/agent.log"
echo "3. Run your application with: ./setup_apm.sh"
echo "4. View APM data at: https://app.datadoghq.com/apm/services"
echo ""
echo "🔧 Useful commands:"
echo "   sudo datadog-agent status       # Check agent status"
echo "   sudo datadog-agent check apm    # Check APM configuration"
echo "   sudo systemctl restart datadog-agent  # Restart agent"