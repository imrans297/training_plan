#!/bin/bash

# DataDog APM Setup Script for Weather Application

echo "🚀 Setting up DataDog APM for Weather Application..."

# Step 1: Set environment variables
export DD_SERVICE="weather-app"
export DD_ENV="development"
export DD_VERSION="1.0.0"
export DD_TRACE_AGENT_URL="http://localhost:8126"
export DD_LOGS_INJECTION="true"
export DD_TRACE_SAMPLE_RATE="1.0"

echo "✅ Environment variables set:"
echo "   DD_SERVICE: $DD_SERVICE"
echo "   DD_ENV: $DD_ENV"
echo "   DD_VERSION: $DD_VERSION"

# Step 2: Install Python dependencies
echo "📦 Installing Python dependencies..."
pip3 install -r requirements_clean.txt

# Step 3: Check if DataDog agent is running
echo "🔍 Checking DataDog agent status..."
if systemctl is-active --quiet datadog-agent; then
    echo "✅ DataDog agent is running"
else
    echo "❌ DataDog agent is not running. Please start it with:"
    echo "   sudo systemctl start datadog-agent"
    exit 1
fi

# Step 4: Test agent connectivity
echo "🌐 Testing agent connectivity..."
curl -s http://localhost:8126/info > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ APM agent is accessible"
else
    echo "❌ APM agent is not accessible on port 8126"
    echo "   Check agent configuration and firewall settings"
fi

# Step 5: Run the application with APM
echo "🎯 Starting Weather Application with APM..."
echo "   Application will be available at: http://localhost:8000"
echo "   Health check endpoint: http://localhost:8000/health"
echo ""
echo "📊 Monitor your application at:"
echo "   DataDog APM: https://app.datadoghq.com/apm/services"
echo ""

# Run with ddtrace
ddtrace-run python3 weather_apm.py