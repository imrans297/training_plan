#!/bin/bash
# ================================
# Setup Nginx with custom default.html
# ================================

# Update system
sudo apt-get update -y

# Install Nginx
sudo apt-get install -y nginx

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Get hostname and primary IP
HOSTNAME=$(hostname)
IPADDR=$(hostname -I | awk '{print $1}')

# Create custom index.html
sudo bash -c "cat > /var/www/html/index.html <<EOF
<html>
<head>
<title>$HOSTNAME</title>
</head>
<body style=\"font-family: Arial; text-align: center; margin-top: 100px;\">
<h1>This is $HOSTNAME</h1>
<p>IP Address: $IPADDR</p>
</body>
</html>
EOF"

# Restart Nginx to apply changes
sudo systemctl restart nginx

echo "✅ Web server setup complete. Access http://$IPADDR to view the page."
