# Azure Learning Journey

## Overview
This directory contains comprehensive documentation for Azure learning with hands-on manual approach, including screenshots and detailed step-by-step guides.

## Directory Structure
```
Azure/
├── Section_1_Fundamentals/
│   ├── Documentation/          # Learning notes and guides
│   ├── Screenshots/           # Portal screenshots and diagrams
│   ├── Hands_on_Labs/        # Lab exercises and results
│   └── Notes/                # Quick notes and references
├── Section_2_Compute/
├── Section_3_Storage/
├── Section_4_Virtual_Networks/  # Current focus
├── Section_5_Security/
└── Section_6_Monitoring/
```

## Current Focus: Section 4 - Virtual Networks

### Learning Approach
- **Manual Configuration**: Using Azure Portal for hands-on experience
- **Screenshot Documentation**: Visual proof of each step
- **Step-by-Step Guides**: Detailed instructions for reproducibility
- **Troubleshooting Notes**: Common issues and solutions

### Screenshot Naming Convention
```
[section]_[lab]_[step]_[description].png

Examples:
- 01_vnet_creation_basics.png
- 02_subnet_configuration.png
- 03_nsg_rules_setup.png
```

## Progress Tracking

### Completed Sections
- [ ] Section 1: Azure Fundamentals
- [ ] Section 2: Compute Services
- [ ] Section 3: Storage Solutions
- [x] Section 4: Virtual Networks (In Progress)
- [ ] Section 5: Security & Identity
- [ ] Section 6: Monitoring & Management

### Current Lab Status
- [x] Lab 1: Basic VNet Creation
- [ ] Lab 2: Subnet Configuration
- [ ] Lab 3: Network Security Groups
- [ ] Lab 4: VNet Peering
- [ ] Lab 5: VPN Gateway Setup

## Quick Reference

### Essential Azure Networking Commands
```bash
# Azure CLI
az network vnet list
az network vnet show --name vnet-name --resource-group rg-name

# PowerShell
Get-AzVirtualNetwork
New-AzVirtualNetwork
```

### Useful Links
- [Azure Portal](https://portal.azure.com)
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)

## Notes
- All screenshots are stored in respective Screenshots/ directories
- Lab exercises include both manual steps and CLI/PowerShell alternatives
- Each section builds upon previous knowledge
- Focus on understanding concepts through manual configuration first