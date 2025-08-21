# ASG Cross-Network Lab - Built From Scratch

## Lab Objective
Create complete infrastructure from scratch to test Application Security Group functionality across different networks.

---

## Infrastructure Built

### Step 1: Virtual Network Creation
**Created**: App-network
- **Region**: East US
- **Address Space**: 10.0.0.0/16
- **Subnet**: web-subnet (10.0.1.0/24)

![alt text](image-13.png)

### Step 2: Virtual Machine Deployment
**Created**: webvm-Linux-01
- **Region**: East US (Zone 1)
- **Image**: Linux (Ubuntu 24.04)
- **Size**: Standard B1s (1 vCPU, 1 GiB memory)
- **Network**: App-network/web-subnet
- **Public IP**: 48.217.187.139

![alt text](image-15.png)

**Network Configuration**:
![alt text](image-16.png)

**VM Deployment Complete**:
![alt text](image-17.png)

---

## Step 3: Application Security Group Setup

### Creating ASG
**Created**: web-servers-asg
- **Region**: East US
- **Purpose**: Group web tier VMs

![alt text](image-18.png)

### Attaching ASG to VM
1. Navigate to webvm-Linux-01 → Networking
2. Click Network Interface
3. Go to Application Security Groups
4. Associate with web-servers-asg

![alt text](image-19.png)

**ASG Association Complete**:
![alt text](image-20.png)

---

## Step 4: Create Second Network for Cross-Network Testing

### New VNet Creation
**Creating**: test-network
- **Region**: East US (same region)
- **Address Space**: 172.16.0.0/16
- **Subnet**: test-subnet (172.16.0.0/24)

![alt text](image-21.png)

### Second VM Creation
**Creating**: testvm-Linux-01
- **Region**: East US
- **Network**: test-network/test-subnet
- **Image**: Ubuntu 24.04
- **Size**: Standard B1s

![alt text](image-22.png)

---

## Not Possible due to its created in another network
