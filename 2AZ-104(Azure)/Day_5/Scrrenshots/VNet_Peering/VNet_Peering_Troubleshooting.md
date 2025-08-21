# VNet Peering Troubleshooting - Asymmetric Connectivity

## Issue Description
- ✅ **testvm-Linux-01 → webvm-Linux-01**: Working (172.16.0.4 → 10.0.0.4)
- ❌ **webvm-Linux-01 → testvm-Linux-01**: Not working (10.0.0.4 → 172.16.0.4)

## Diagnostic Results

### VM IP Addresses Confirmed:
```
webvm-Linux-01:  10.0.0.4   (App-network)
testvm-Linux-01: 172.16.0.4 (test-network)
```

### Peering Status: ✅ GOOD
```
App-network ↔ test-network: Connected, FullyInSync
```

### Routes: ✅ GOOD
```
webvm-Linux-01 effective routes:
- 10.0.0.0/16    → VnetLocal
- 172.16.0.0/16  → VNetPeering  ✅ Route exists!
```

### NSG Rules: ⚠️ POTENTIAL ISSUE
```
webvm-linux-01-nsg:
- SSH (TCP/22): Allow
- HTTP (TCP/80): Allow  
- ICMP: Allow (Inbound only)
```

## Root Cause Analysis

### Issue: Missing Outbound ICMP Rule
The webvm NSG has **inbound ICMP** allowed but may be missing **outbound ICMP** rule.

### Why One Direction Works:
- **testvm → webvm**: testvm can send ICMP out, webvm allows ICMP in ✅
- **webvm → testvm**: webvm may be blocked from sending ICMP out ❌

---

## Solution 1: Add Outbound ICMP Rule to webvm NSG

### Azure CLI Fix:
```bash
az network nsg rule create \
  --resource-group Azure_RG \
  --nsg-name webvm-linux-01-nsg \
  --name AllowICMPOutbound \
  --protocol ICMP \
  --direction Outbound \
  --source-address-prefix "*" \
  --destination-address-prefix "*" \
  --access Allow \
  --priority 100
```

### Portal Fix:
1. Navigate to webvm-linux-01-nsg
2. Go to Outbound security rules
3. Add rule:
   - **Name**: AllowICMPOutbound
   - **Protocol**: ICMP
   - **Direction**: Outbound
   - **Action**: Allow
   - **Priority**: 100

![alt text](troubleshoot-image-1.png)

---

## Solution 2: Check testvm NSG for Inbound ICMP

### Verify testvm allows inbound ICMP:
```bash
az network nsg rule list \
  --resource-group Azure_RG \
  --nsg-name testvm-Linux-01-nsg \
  --query "[?protocol=='ICMP' && direction=='Inbound']" \
  --output table
```

### Add inbound ICMP rule if missing:
```bash
az network nsg rule create \
  --resource-group Azure_RG \
  --nsg-name testvm-Linux-01-nsg \
  --name AllowICMPInbound \
  --protocol ICMP \
  --direction Inbound \
  --source-address-prefix "*" \
  --destination-address-prefix "*" \
  --access Allow \
  --priority 100
```

---

## Alternative Testing Methods

### Since you're using Bastion, try these tests:

### 1. Test with Bastion SSH Session
```bash
# Connect to webvm via Bastion
# Then test ping from within the SSH session
ping 172.16.0.4
```

### 2. Test TCP Connectivity Instead of ICMP
```bash
# On testvm-Linux-01 (via its public IP or Bastion)
nc -l 8080

# On webvm-Linux-01 (via Bastion)
nc -zv 172.16.0.4 8080
```

### 3. Test with Telnet
```bash
# On webvm-Linux-01 (via Bastion)
telnet 172.16.0.4 22  # SSH port should be open
```

---

## Verification Steps

### After applying the fix:

### 1. Test ICMP from webvm
```bash
# Via Bastion SSH to webvm-Linux-01
ping 172.16.0.4
# Should now work ✅
```

### 2. Test bidirectional connectivity
```bash
# From testvm-Linux-01
ping 10.0.0.4  # Should still work ✅

# From webvm-Linux-01  
ping 172.16.0.4  # Should now work ✅
```

### 3. Verify NSG rules
```bash
# Check outbound rules for webvm NSG
az network nsg rule list \
  --resource-group Azure_RG \
  --nsg-name webvm-linux-01-nsg \
  --query "[?direction=='Outbound']" \
  --output table
```

---

## Common VNet Peering Issues

### 1. Asymmetric NSG Rules ⚠️
- **Problem**: Different NSG rules on each side
- **Solution**: Ensure both inbound and outbound rules match

### 2. Route Table Conflicts
- **Problem**: Custom route tables overriding peering routes
- **Solution**: Check for conflicting user-defined routes

### 3. Firewall on VM
- **Problem**: OS-level firewall blocking traffic
- **Solution**: Check iptables/ufw on Linux VMs

### 4. Wrong IP Addresses
- **Problem**: Using public IP instead of private IP
- **Solution**: Always use private IPs for peered communication

---

## Best Practices for VNet Peering

### 1. NSG Rule Symmetry
- Ensure both VNets have matching allow rules
- Consider both inbound and outbound directions

### 2. Testing Strategy
- Test both directions
- Test multiple protocols (ICMP, TCP, UDP)
- Use private IPs only

### 3. Documentation
- Document all NSG rules
- Keep track of peering configurations
- Monitor connectivity regularly

---

## Quick Fix Command

Run this command to fix the issue immediately:

```bash
az network nsg rule create \
  --resource-group Azure_RG \
  --nsg-name webvm-linux-01-nsg \
  --name AllowICMPOutbound \
  --protocol ICMP \
  --direction Outbound \
  --source-address-prefix "*" \
  --destination-address-prefix "*" \
  --access Allow \
  --priority 100
```

**Expected Result**: webvm-Linux-01 should now be able to ping testvm-Linux-01 at 172.16.0.4

## Status: 🔧 **ISSUE IDENTIFIED** - Missing outbound ICMP rule on webvm NSG