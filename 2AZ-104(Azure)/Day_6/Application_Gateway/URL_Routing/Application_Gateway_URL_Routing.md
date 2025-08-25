# Azure Application Gateway - URL Routing Implementation

## What is Application Gateway?
Layer 7 (HTTP/HTTPS) load balancer with advanced routing, SSL termination, and WAF capabilities.

## Application Gateway vs Load Balancer

| Feature | Load Balancer | Application Gateway |
|---------|---------------|-------------------|
| **Layer** | Layer 4 (TCP/UDP) | Layer 7 (HTTP/HTTPS) |
| **Routing** | IP/Port based | URL/Header based |
| **SSL Termination** | No | Yes |
| **WAF** | No | Yes |
| **Cost** | Lower | Higher |

---

## Lab Architecture - URL Routing

```
Internet → Application Gateway → Backend Pools
├── /api/* → API Backend (appvm-linux-01)
├── /images/* → Images Backend (webvm-linux-01)
├── /videos/* → Videos Backend (webvm-linux-02)
└── /* → Default Backend (All VMs)
```

---

## Step 1: Prepare Backend VMs

### Create Different Content

#### API Server (appvm-linux-01):
```bash
sudo mkdir -p /var/www/html/api
echo "<h1>API Server</h1><p>appvm-linux-01</p>" | sudo tee /var/www/html/api/index.html
```

#### Images Server (webvm-linux-01):
```bash
sudo mkdir -p /var/www/html/images
echo "<h1>Images Server</h1><p>webvm-linux-01</p>" | sudo tee /var/www/html/images/index.html
```

#### Videos Server (webvm-linux-02):
```bash
sudo mkdir -p /var/www/html/videos
echo "<h1>Videos Server</h1><p>webvm-linux-02</p>" | sudo tee /var/www/html/videos/index.html
```

![alt text](url-routing-image-1.png)

---

## Step 2: Create Application Gateway

### Configuration:
- **Name**: `appgw-url-routing`
- **Tier**: `Standard_v2`
- **Autoscaling**: Min 2, Max 10
- **VNet**: `app-network`
- **Subnet**: Create `appgw-subnet (10.0.4.0/24)`

![alt text](url-routing-image-2.png)

---

## Step 3: Configure Backend Pools

### Backend Pools:
1. **backend-api**: appvm-linux-01 (10.0.2.4)
2. **backend-images**: webvm-linux-01 (10.0.0.4)
3. **backend-videos**: webvm-linux-02 (10.0.0.5)
4. **backend-default**: All three VMs

![alt text](url-routing-image-3.png)

---

## Step 4: Configure HTTP Settings

### HTTP Settings:
- **http-settings-api**: Port 80, HTTP
- **http-settings-images**: Port 80, HTTP
- **http-settings-videos**: Port 80, HTTP

![alt text](url-routing-image-4.png)

---

## Step 5: Configure Health Probes

### Custom Probes:
- **probe-api**: Path `/api/`
- **probe-images**: Path `/images/`
- **probe-videos**: Path `/videos/`

![alt text](url-routing-image-5.png)

---

## Step 6: Create URL Routing Rules

### Listener:
- **Name**: `listener-http`
- **Protocol**: `HTTP`
- **Port**: `80`

### Path-based Rules:
1. `/api/*` → backend-api
2. `/images/*` → backend-images
3. `/videos/*` → backend-videos
4. `/*` → backend-default

![alt text](url-routing-image-6.png)

---

## Step 7: Test URL Routing

### Test Commands:
```bash
APPGW_IP="APPLICATION_GATEWAY_PUBLIC_IP"

# Test API routing
curl http://$APPGW_IP/api/
# Returns: "API Server - appvm-linux-01"

# Test Images routing
curl http://$APPGW_IP/images/
# Returns: "Images Server - webvm-linux-01"

# Test Videos routing
curl http://$APPGW_IP/videos/
# Returns: "Videos Server - webvm-linux-02"
```

![alt text](url-routing-image-7.png)

---

## Step 8: Advanced Routing Features

### Query String Routing:
- Path: `/search*`
- Query: `type=product`
- Backend: `backend-api`

### Header-based Routing:
- Path: `/mobile/*`
- Header: `User-Agent: Mobile*`
- Backend: `backend-images`

![alt text](url-routing-image-8.png)

---

## Step 9: Monitor Application Gateway

### Key Metrics:
- **Total Requests**: Traffic volume
- **Failed Requests**: Error rate
- **Response Time**: Performance
- **Backend Health**: Server status

![alt text](url-routing-image-9.png)

---

## URL Routing Benefits

### 1. Intelligent Distribution
- **Path-based**: Route by URL path
- **Query-based**: Route by parameters
- **Header-based**: Route by headers

### 2. Microservices Support
- **Service Separation**: Different paths to services
- **Independent Scaling**: Scale services separately
- **Technology Diversity**: Different backends

### 3. Performance Optimization
- **Specialized Backends**: Optimized servers
- **Caching Strategies**: Content-specific caching
- **Resource Optimization**: Right-sized backends

---

## Best Practices

### 1. Path Design
- **Consistent Patterns**: Use standard URL patterns
- **Specific to General**: Order rules appropriately
- **Wildcard Usage**: Use wildcards correctly

### 2. Backend Strategy
- **Service Alignment**: Align pools with services
- **Health Monitoring**: Configure proper probes
- **Capacity Planning**: Size based on load

### 3. Performance
- **Connection Draining**: Enable for maintenance
- **Session Affinity**: Use when needed
- **Timeout Optimization**: Set appropriate timeouts

---

## Lab Results

### Successfully Implemented:
- ✅ **Application Gateway**: Layer 7 load balancer
- ✅ **URL Routing**: Path-based distribution
- ✅ **Backend Pools**: Service-specific backends
- ✅ **Health Monitoring**: Custom probes
- ✅ **Advanced Routing**: Query/header routing

**Lab Status**: ✅ **COMPLETED** - URL Routing implemented