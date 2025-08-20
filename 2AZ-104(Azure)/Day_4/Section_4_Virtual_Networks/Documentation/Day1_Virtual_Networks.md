# Azure Virtual Networks - Day 1 Learning Log

## Date: $(date +"%B %d, %Y")

---

## Section 4: Azure Virtual Networks - Manual Approach

### Learning Objectives
- [ ] Understand Azure Virtual Network fundamentals
- [ ] Create Virtual Networks manually through Azure Portal
- [ ] Configure subnets and address spaces
- [ ] Implement Network Security Groups (NSGs)
- [ ] Set up Virtual Network Peering
- [ ] Configure routing and connectivity

---

## Hands-on Lab Activities

### Lab 1: Creating Your First Virtual Network

#### Prerequisites
- Azure subscription (Free tier or paid)
- Access to Azure Portal
- Basic understanding of networking concepts

#### Step-by-Step Manual Creation

**1. Access Azure Portal**
- Navigate to: https://portal.azure.com
- Sign in with your Azure credentials
- Screenshot: `01_azure_portal_login.png`

**2. Create Resource Group**
```
Resource Group Name: rg-vnet-learning
Region: East US (or your preferred region)
```
- Screenshot: `02_resource_group_creation.png`

**3. Create Virtual Network**
```
Virtual Network Name: vnet-learning-001
Address Space: 10.0.0.0/16
Subnet Name: subnet-web
Subnet Address Range: 10.0.1.0/24
```
- Screenshot: `03_vnet_creation_basics.png`
- Screenshot: `04_vnet_creation_subnets.png`

**4. Verify Virtual Network Creation**
- Navigate to Virtual Networks in Azure Portal
- Verify configuration and settings
- Screenshot: `05_vnet_overview.png`

#### Configuration Details
| Setting | Value | Notes |
|---------|-------|-------|
| Subscription | [Your Subscription] | |
| Resource Group | rg-vnet-learning | |
| Name | vnet-learning-001 | |
| Region | East US | |
| IPv4 Address Space | 10.0.0.0/16 | Provides 65,536 IP addresses |
| Subnet Name | subnet-web | |
| Subnet Range | 10.0.1.0/24 | Provides 256 IP addresses |

---

### Lab 2: Adding Additional Subnets

#### Manual Subnet Creation
**1. Navigate to Virtual Network**
- Go to your created VNet: vnet-learning-001
- Select "Subnets" from left menu

**2. Add Database Subnet**
```
Subnet Name: subnet-database
Address Range: 10.0.2.0/24
```
- Screenshot: `06_subnet_database_creation.png`

**3. Add Application Subnet**
```
Subnet Name: subnet-app
Address Range: 10.0.3.0/24
```
- Screenshot: `07_subnet_app_creation.png`

#### Updated Network Architecture
```
vnet-learning-001 (10.0.0.0/16)
├── subnet-web (10.0.1.0/24)
├── subnet-database (10.0.2.0/24)
└── subnet-app (10.0.3.0/24)
```

---

### Lab 3: Network Security Groups (NSGs)

#### Creating NSG for Web Subnet
**1. Create Network Security Group**
```
NSG Name: nsg-web-subnet
Resource Group: rg-vnet-learning
Region: East US
```
- Screenshot: `08_nsg_creation.png`

**2. Configure Inbound Security Rules**
| Priority | Name | Port | Protocol | Source | Action |
|----------|------|------|----------|--------|--------|
| 100 | Allow-HTTP | 80 | TCP | Internet | Allow |
| 110 | Allow-HTTPS | 443 | TCP | Internet | Allow |
| 120 | Allow-SSH | 22 | TCP | My IP | Allow |

- Screenshot: `09_nsg_inbound_rules.png`

**3. Associate NSG with Subnet**
- Navigate to subnet-web
- Associate nsg-web-subnet
- Screenshot: `10_nsg_subnet_association.png`

---

## Key Concepts Learned

### 1. Virtual Network Fundamentals
- **Address Space**: Private IP range for your virtual network
- **Subnets**: Logical divisions within your VNet
- **Region**: Geographic location where resources are deployed
- **Resource Group**: Container for related Azure resources

### 2. Subnet Planning
- **CIDR Notation**: Understanding /16, /24 notation
- **IP Address Allocation**: How Azure reserves IP addresses
- **Subnet Sizing**: Planning for future growth

### 3. Network Security
- **NSG Rules**: Inbound and outbound traffic control
- **Priority**: Lower numbers have higher priority
- **Default Rules**: Azure's built-in security rules

---

## Screenshots Captured Today

### Portal Navigation
- [ ] `01_azure_portal_login.png` - Azure Portal login screen
- [ ] `02_resource_group_creation.png` - Resource group creation
- [ ] `03_vnet_creation_basics.png` - VNet basic configuration
- [ ] `04_vnet_creation_subnets.png` - Initial subnet configuration
- [ ] `05_vnet_overview.png` - Completed VNet overview

### Subnet Configuration
- [ ] `06_subnet_database_creation.png` - Database subnet creation
- [ ] `07_subnet_app_creation.png` - Application subnet creation

### Security Configuration
- [ ] `08_nsg_creation.png` - NSG creation process
- [ ] `09_nsg_inbound_rules.png` - Inbound security rules
- [ ] `10_nsg_subnet_association.png` - NSG to subnet association

---

## Commands and PowerShell (for reference)

### Azure CLI Commands
```bash
# Login to Azure
az login

# Create Resource Group
az group create --name rg-vnet-learning --location eastus

# Create Virtual Network
az network vnet create \
  --resource-group rg-vnet-learning \
  --name vnet-learning-001 \
  --address-prefix 10.0.0.0/16 \
  --subnet-name subnet-web \
  --subnet-prefix 10.0.1.0/24

# Add additional subnets
az network vnet subnet create \
  --resource-group rg-vnet-learning \
  --vnet-name vnet-learning-001 \
  --name subnet-database \
  --address-prefix 10.0.2.0/24
```

### PowerShell Commands
```powershell
# Connect to Azure
Connect-AzAccount

# Create Resource Group
New-AzResourceGroup -Name "rg-vnet-learning" -Location "East US"

# Create Virtual Network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName "rg-vnet-learning" `
  -Location "East US" `
  -Name "vnet-learning-001" `
  -AddressPrefix "10.0.0.0/16"
```

---

## Troubleshooting Notes

### Common Issues Encountered
1. **Issue**: Subnet address ranges overlapping
   - **Solution**: Ensure non-overlapping CIDR blocks
   - **Screenshot**: `troubleshoot_01_subnet_overlap.png`

2. **Issue**: NSG rules not taking effect
   - **Solution**: Check rule priority and association
   - **Screenshot**: `troubleshoot_02_nsg_rules.png`

---

## Next Steps for Tomorrow

### Planned Activities
- [ ] Create Virtual Network Peering
- [ ] Set up VPN Gateway
- [ ] Configure custom DNS
- [ ] Implement Network Watcher
- [ ] Test connectivity between subnets

### Resources to Review
- Microsoft Learn: Azure Virtual Networks
- Azure Documentation: VNet best practices
- Azure Architecture Center: Network topologies

---

## Daily Summary

### Time Spent: __ hours
### Difficulty Level: Beginner/Intermediate/Advanced
### Confidence Level: 1-10 scale

### What Went Well:
- Successfully created first Virtual Network
- Understood subnet planning concepts
- Configured basic network security

### Challenges Faced:
- [List any challenges encountered]

### Key Takeaways:
1. Virtual Networks are the foundation of Azure networking
2. Proper subnet planning is crucial for scalability
3. NSGs provide essential security controls
4. Manual approach helps understand underlying concepts

---

## Additional Notes
[Add any additional observations, tips, or insights from today's learning]