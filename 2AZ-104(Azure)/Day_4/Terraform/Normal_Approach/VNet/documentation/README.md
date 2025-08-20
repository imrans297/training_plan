# Normal Approach - Virtual Network Terraform Configuration

## Overview
This directory contains Terraform configuration files for creating Azure Virtual Network infrastructure using the **Normal Approach** - a straightforward, single-configuration method suitable for learning and simple deployments.

## Architecture
The configuration creates the following Azure resources:

```
Resource Group: rg-terraform-vnet-normal
└── Virtual Network: vnet-terraform-normal (10.0.0.0/16)
    ├── Web Subnet: subnet-web (10.0.1.0/24)
    │   └── NSG: subnet-web-nsg
    ├── App Subnet: subnet-app (10.0.2.0/24)
    │   └── NSG: subnet-app-nsg
    └── Database Subnet: subnet-database (10.0.3.0/24)
        └── NSG: subnet-database-nsg
```

## Files Description

### Core Terraform Files
- **`main.tf`**: Main configuration file containing all resource definitions
- **`variables.tf`**: Variable definitions with descriptions and default values
- **`outputs.tf`**: Output values for created resources
- **`terraform.tfvars.example`**: Example variables file with different configuration options

### Security Rules
Each subnet has its own Network Security Group (NSG) with appropriate rules:

#### Web Subnet NSG Rules
- **Allow HTTP (80)**: Internet → Web Subnet
- **Allow HTTPS (443)**: Internet → Web Subnet  
- **Allow SSH (22)**: Admin IP → Web Subnet

#### App Subnet NSG Rules
- **Allow App Traffic (8080)**: Web Subnet → App Subnet
- **Allow SSH (22)**: Admin IP → App Subnet

#### Database Subnet NSG Rules
- **Allow Database Traffic (3306)**: App Subnet → Database Subnet
- **Allow SSH (22)**: Admin IP → Database Subnet

## Prerequisites

### 1. Install Required Tools
```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installations
terraform version
az version
```

### 2. Azure Authentication
```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "your-subscription-id"

# Verify current subscription
az account show
```

### 3. Get Your Public IP (for security)
```bash
# Get your public IP address
curl -s https://ipinfo.io/ip

# Or visit: https://whatismyipaddress.com/
```

## Deployment Instructions

### Step 1: Prepare Configuration
```bash
# Navigate to the terraform files directory
cd /path/to/AZ-104/Terraform/Normal_Approach/VNet/terraform_files

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit variables file with your values
nano terraform.tfvars
```

### Step 2: Update terraform.tfvars
```hcl
# Minimum required changes:
resource_group_name = "rg-your-name-vnet"
admin_source_address_prefix = "YOUR_PUBLIC_IP/32"  # Replace with your IP
```

### Step 3: Initialize Terraform
```bash
# Initialize Terraform (downloads providers)
terraform init
```

### Step 4: Plan Deployment
```bash
# Review what will be created
terraform plan

# Save plan to file (optional)
terraform plan -out=tfplan
```

### Step 5: Apply Configuration
```bash
# Deploy infrastructure
terraform apply

# Or apply saved plan
terraform apply tfplan
```

### Step 6: Verify Deployment
```bash
# Show current state
terraform show

# List created resources
az resource list --resource-group rg-your-name-vnet --output table
```

## Customization Options

### Different Environments
Create separate `.tfvars` files for different environments:

```bash
# Development
terraform apply -var-file="dev.tfvars"

# Staging  
terraform apply -var-file="staging.tfvars"

# Production
terraform apply -var-file="prod.tfvars"
```

### Example Environment Files

**dev.tfvars**
```hcl
resource_group_name = "rg-dev-vnet"
environment = "dev"
vnet_name = "vnet-dev"
```

**prod.tfvars**
```hcl
resource_group_name = "rg-prod-vnet"
environment = "prod"
vnet_name = "vnet-prod"
location = "West US"
```

## Validation and Testing

### 1. Resource Validation
```bash
# Check resource group
az group show --name rg-your-name-vnet

# Check virtual network
az network vnet show --resource-group rg-your-name-vnet --name vnet-terraform-normal

# List subnets
az network vnet subnet list --resource-group rg-your-name-vnet --vnet-name vnet-terraform-normal --output table

# Check NSG rules
az network nsg rule list --resource-group rg-your-name-vnet --nsg-name subnet-web-nsg --output table
```

### 2. Connectivity Testing
```bash
# Test name resolution
nslookup vnet-terraform-normal.internal.cloudapp.net

# Check route tables (if any)
az network route-table list --resource-group rg-your-name-vnet
```

## Troubleshooting

### Common Issues

#### 1. Authentication Errors
```bash
# Re-login to Azure
az login --use-device-code

# Check current subscription
az account show
```

#### 2. Permission Issues
```bash
# Check your role assignments
az role assignment list --assignee your-email@domain.com --output table

# Required roles: Contributor or Owner
```

#### 3. Resource Name Conflicts
```bash
# Check if resource group already exists
az group exists --name rg-your-name-vnet

# List existing VNets
az network vnet list --output table
```

#### 4. IP Address Conflicts
```bash
# Check existing VNet address spaces
az network vnet list --query "[].{Name:name, AddressSpace:addressSpace}" --output table
```

### Terraform-Specific Issues

#### 1. State Lock Issues
```bash
# Force unlock (use carefully)
terraform force-unlock LOCK_ID
```

#### 2. State Corruption
```bash
# Refresh state
terraform refresh

# Import existing resource (if needed)
terraform import azurerm_resource_group.main /subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME
```

## Cleanup

### Destroy Resources
```bash
# Destroy all resources
terraform destroy

# Destroy specific resources
terraform destroy -target=azurerm_network_security_group.web
```

### Verify Cleanup
```bash
# Check if resource group is deleted
az group exists --name rg-your-name-vnet

# Should return: false
```

## Cost Considerations

### Resource Costs (Approximate)
- **Resource Group**: Free
- **Virtual Network**: Free
- **Subnets**: Free  
- **Network Security Groups**: Free
- **NSG Rules**: Free

**Total Monthly Cost**: ~$0 (for basic VNet infrastructure)

*Note: Costs apply when you add VMs, Load Balancers, VPN Gateways, etc.*

## Next Steps

After successfully deploying this configuration:

1. **Add Virtual Machines**: Deploy VMs in different subnets
2. **Configure Load Balancer**: Add load balancing for web tier
3. **Set up VPN Gateway**: Enable hybrid connectivity
4. **Implement Monitoring**: Add Network Watcher and monitoring
5. **Learn Modular Approach**: Progress to modular Terraform patterns

## Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Virtual Network Documentation](https://docs.microsoft.com/azure/virtual-network/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [Azure Naming Conventions](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)