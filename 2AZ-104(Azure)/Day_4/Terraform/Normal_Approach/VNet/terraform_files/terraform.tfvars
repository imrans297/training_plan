# Example Terraform Variables File
# Copy this file to terraform.tfvars and modify values as needed

# Resource Group Configuration
resource_group_name = "rg-terraform-vnet-normal"
location            = "East US"
environment         = "dev"

# Virtual Network Configuration
vnet_name          = "vnet-terraform-normal"
vnet_address_space = ["10.0.0.0/16"]

# Web Subnet Configuration
web_subnet_name             = "subnet-web"
web_subnet_address_prefixes = ["10.0.1.0/24"]

# Application Subnet Configuration
app_subnet_name             = "subnet-app"
app_subnet_address_prefixes = ["10.0.2.0/24"]

# Database Subnet Configuration
database_subnet_name             = "subnet-database"
database_subnet_address_prefixes = ["10.0.3.0/24"]

# Security Configuration
# IMPORTANT: Replace with your actual public IP for better security
# You can find your public IP by visiting: https://whatismyipaddress.com/
admin_source_address_prefix = "106.215.180.15/32"

# Alternative configurations for different environments:

# Development Environment
# resource_group_name = "rg-dev-vnet"
# environment        = "dev"
# vnet_name          = "vnet-dev"

# Staging Environment
# resource_group_name = "rg-staging-vnet"
# environment        = "staging"
# vnet_name          = "vnet-staging"

# Production Environment
# resource_group_name = "rg-prod-vnet"
# environment        = "prod"
# vnet_name          = "vnet-prod"
# location           = "West US"

# Different IP Address Ranges (choose one):

# Option 1: 10.x.x.x range (default)
# vnet_address_space = ["10.0.0.0/16"]
# web_subnet_address_prefixes = ["10.0.1.0/24"]
# app_subnet_address_prefixes = ["10.0.2.0/24"]
# database_subnet_address_prefixes = ["10.0.3.0/24"]

# Option 2: 172.16.x.x range
# vnet_address_space = ["172.16.0.0/16"]
# web_subnet_address_prefixes = ["172.16.1.0/24"]
# app_subnet_address_prefixes = ["172.16.2.0/24"]
# database_subnet_address_prefixes = ["172.16.3.0/24"]

# Option 3: 192.168.x.x range
# vnet_address_space = ["192.168.0.0/16"]
# web_subnet_address_prefixes = ["192.168.1.0/24"]
# app_subnet_address_prefixes = ["192.168.2.0/24"]
# database_subnet_address_prefixes = ["192.168.3.0/24"]