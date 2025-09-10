# Docker Complete Guide

## Table of Contents
1. [What is Docker?](#what-is-docker)
2. [Docker Architecture](#docker-architecture)
3. [Docker Installation](#docker-installation)
4. [Docker Images](#docker-images)
5. [Docker Containers](#docker-containers)
6. [Docker Run Command](#docker-run-command)
7. [Dockerfile](#dockerfile)
8. [Docker Compose](#docker-compose)
9. [Docker Registry](#docker-registry)
10. [Docker Engine](#docker-engine)
11. [Docker Storage](#docker-storage)
12. [Docker Networking](#docker-networking)
13. [Best Practices](#best-practices)
14. [Troubleshooting](#troubleshooting)

## What is Docker?

### Definition
Docker is a containerization platform that enables developers to package applications and their dependencies into lightweight, portable containers. These containers can run consistently across different environments, from development to production.

### Key Concepts

#### Container vs Virtual Machine
```
Virtual Machine:
┌─────────────────────────────────┐
│        Application             │
├─────────────────────────────────┤
│        Guest OS                │
├─────────────────────────────────┤
│        Hypervisor              │
├─────────────────────────────────┤
│        Host OS                 │
├─────────────────────────────────┤
│        Physical Hardware       │
└─────────────────────────────────┘

Container:
┌─────────────────────────────────┐
│        Application             │
├─────────────────────────────────┤
│        Container Runtime       │
├─────────────────────────────────┤
│        Host OS                 │
├─────────────────────────────────┤
│        Physical Hardware       │
└─────────────────────────────────┘
```

#### Benefits of Docker
- **Portability**: Run anywhere Docker is installed
- **Consistency**: Same environment across development, testing, and production
- **Efficiency**: Lightweight compared to VMs
- **Scalability**: Easy to scale applications horizontally
- **Isolation**: Applications run in isolated environments
- **Speed**: Fast startup and deployment times

## Docker Architecture

### Core Components

#### 1. Docker Client
- Command-line interface (CLI)
- Communicates with Docker daemon
- Sends commands like `docker build`, `docker run`

#### 2. Docker Daemon (dockerd)
- Background service running on host
- Manages Docker objects (images, containers, networks, volumes)
- Listens for Docker API requests

#### 3. Docker Images
- Read-only templates used to create containers
- Built from Dockerfile instructions
- Stored in layers for efficiency

#### 4. Docker Containers
- Runnable instances of Docker images
- Isolated processes with their own filesystem
- Can be started, stopped, moved, and deleted

#### 5. Docker Registry
- Storage and distribution system for Docker images
- Docker Hub is the default public registry
- Can be private or public

### Architecture Diagram
```
┌─────────────────┐    ┌─────────────────────────────────┐
│   Docker CLI    │───▶│        Docker Host              │
│                 │    │  ┌─────────────────────────────┐ │
└─────────────────┘    │  │      Docker Daemon          │ │
                       │  │  ┌─────────────────────────┐ │ │
┌─────────────────┐    │  │  │     Containers          │ │ │
│  Docker Registry│◀───┼──┼──│  ┌───┐ ┌───┐ ┌───┐     │ │ │
│   (Docker Hub)  │    │  │  │  │ C1│ │C2 │ │C3 │     │ │ │
└─────────────────┘    │  │  │  └───┘ └───┘ └───┘     │ │ │
                       │  │  └─────────────────────────┘ │ │
                       │  │  ┌─────────────────────────┐ │ │
                       │  │  │        Images           │ │ │
                       │  │  │  ┌───┐ ┌───┐ ┌───┐     │ │ │
                       │  │  │  │ I1│ │I2 │ │I3 │     │ │ │
                       │  │  │  └───┘ └───┘ └───┘     │ │ │
                       │  │  └─────────────────────────┘ │ │
                       │  └─────────────────────────────┘ │
                       └─────────────────────────────────┘
```

## Docker Installation

### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group (optional)
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### Verification
```bash
# Check Docker version
docker --version

# Run hello-world container
docker run hello-world

# Check Docker info
docker info
```

## Docker Images

### What are Docker Images?
Docker images are read-only templates containing:
- Application code
- Runtime environment
- System tools and libraries
- Environment variables
- Configuration files

### Image Layers
Images are built in layers:
```
┌─────────────────────┐ ← Application Layer
├─────────────────────┤ ← Dependencies Layer
├─────────────────────┤ ← Runtime Layer
├─────────────────────┤ ← OS Layer
└─────────────────────┘ ← Base Layer
```

### Image Commands

#### List Images
```bash
# List all images
docker images
docker image ls

# List images with specific format
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

#### Pull Images
```bash
# Pull latest version
docker pull nginx

# Pull specific version
docker pull nginx:1.21

# Pull from specific registry
docker pull registry.example.com/nginx:latest
```

#### Build Images
```bash
# Build from Dockerfile in current directory
docker build -t myapp:latest .

# Build with specific Dockerfile
docker build -f Dockerfile.prod -t myapp:prod .

# Build with build arguments
docker build --build-arg VERSION=1.0 -t myapp:1.0 .
```

#### Remove Images
```bash
# Remove specific image
docker rmi nginx:latest

# Remove multiple images
docker rmi image1 image2 image3

# Remove all unused images
docker image prune

# Remove all images
docker rmi $(docker images -q)
```

#### Image Information
```bash
# Inspect image details
docker inspect nginx:latest

# View image history
docker history nginx:latest

# Save image to tar file
docker save -o nginx.tar nginx:latest

# Load image from tar file
docker load -i nginx.tar
```

## Docker Containers

### What are Containers?
Containers are running instances of Docker images that include:
- Isolated filesystem
- Process space
- Network interface
- Resource limits

### Container Lifecycle
```
Created → Running → Paused → Stopped → Removed
    ↑         ↓         ↑         ↓
    └─────────┴─────────┴─────────┘
```

### Container Commands

#### List Containers
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List containers with custom format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

#### Create and Start Containers
```bash
# Create container without starting
docker create --name mycontainer nginx

# Start existing container
docker start mycontainer

# Create and start container
docker run --name mycontainer nginx
```

#### Stop and Remove Containers
```bash
# Stop running container
docker stop mycontainer

# Kill container (force stop)
docker kill mycontainer

# Remove stopped container
docker rm mycontainer

# Remove running container (force)
docker rm -f mycontainer

# Remove all stopped containers
docker container prune
```

#### Container Interaction
```bash
# Execute command in running container
docker exec -it mycontainer bash

# View container logs
docker logs mycontainer

# Follow log output
docker logs -f mycontainer

# Copy files to/from container
docker cp file.txt mycontainer:/path/to/destination
docker cp mycontainer:/path/to/file.txt ./local-file.txt

# View container resource usage
docker stats mycontainer
```

## Docker Run Command

### Basic Syntax
```bash
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

### Common Options

#### Port Mapping
```bash
# Map container port to host port
docker run -p 8080:80 nginx

# Map to random host port
docker run -P nginx

# Map multiple ports
docker run -p 8080:80 -p 8443:443 nginx
```

#### Volume Mounting
```bash
# Bind mount host directory
docker run -v /host/path:/container/path nginx

# Named volume
docker run -v myvolume:/container/path nginx

# Read-only mount
docker run -v /host/path:/container/path:ro nginx
```

#### Environment Variables
```bash
# Set single environment variable
docker run -e ENV_VAR=value nginx

# Set multiple environment variables
docker run -e VAR1=value1 -e VAR2=value2 nginx

# Load from file
docker run --env-file .env nginx
```

#### Container Naming and Detached Mode
```bash
# Run in background (detached)
docker run -d nginx

# Assign custom name
docker run --name webserver nginx

# Interactive mode with TTY
docker run -it ubuntu bash

# Remove container after exit
docker run --rm nginx
```

#### Resource Limits
```bash
# Limit memory
docker run -m 512m nginx

# Limit CPU
docker run --cpus="1.5" nginx

# Set CPU and memory limits
docker run -m 1g --cpus="2" nginx
```

#### Network Configuration
```bash
# Use specific network
docker run --network mynetwork nginx

# Publish all exposed ports
docker run -P nginx

# Set hostname
docker run --hostname webserver nginx
```

### Complete Example
```bash
docker run -d \
  --name my-web-app \
  -p 8080:80 \
  -v /host/data:/app/data \
  -e NODE_ENV=production \
  -e API_KEY=secret123 \
  --memory=512m \
  --cpus="1" \
  --restart=unless-stopped \
  nginx:latest
```

## Dockerfile

### What is a Dockerfile?
A Dockerfile is a text file containing instructions to build a Docker image automatically.

### Dockerfile Instructions

#### FROM
```dockerfile
# Base image
FROM ubuntu:20.04

# Multi-stage build
FROM node:16 AS builder
FROM nginx:alpine AS runtime
```

#### RUN
```dockerfile
# Execute commands during build
RUN apt-get update && apt-get install -y curl

# Multiple commands
RUN apt-get update \
    && apt-get install -y \
        curl \
        wget \
        vim \
    && rm -rf /var/lib/apt/lists/*
```

#### COPY and ADD
```dockerfile
# Copy files from host to image
COPY app.js /usr/src/app/
COPY package*.json ./

# ADD can extract archives and download URLs
ADD https://example.com/file.tar.gz /tmp/
ADD archive.tar.gz /usr/src/app/
```

#### WORKDIR
```dockerfile
# Set working directory
WORKDIR /usr/src/app

# All subsequent commands run from this directory
RUN npm install
COPY . .
```

#### ENV
```dockerfile
# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV DATABASE_URL=postgresql://localhost/mydb
```

#### EXPOSE
```dockerfile
# Document which ports the container listens on
EXPOSE 3000
EXPOSE 80 443
```

#### CMD and ENTRYPOINT
```dockerfile
# CMD - default command (can be overridden)
CMD ["node", "app.js"]
CMD node app.js

# ENTRYPOINT - always executed (cannot be overridden)
ENTRYPOINT ["node"]
CMD ["app.js"]

# Combined usage
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
```

#### USER
```dockerfile
# Set user for subsequent instructions
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
```

#### VOLUME
```dockerfile
# Create mount points
VOLUME ["/data"]
VOLUME /var/log /var/db
```

#### ARG
```dockerfile
# Build-time variables
ARG VERSION=latest
ARG BUILD_DATE
FROM node:${VERSION}
LABEL build-date=${BUILD_DATE}
```

### Complete Dockerfile Example

#### Node.js Application
```dockerfile
# Multi-stage build for Node.js app
FROM node:16-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM node:16-alpine AS production

# Create app user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Set working directory
WORKDIR /usr/src/app

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /usr/src/app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /usr/src/app/package.json ./package.json

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["node", "dist/index.js"]
```

#### Python Flask Application
```dockerfile
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 5000

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

### Build Best Practices
```dockerfile
# Use specific tags, not 'latest'
FROM node:16.14.2-alpine

# Combine RUN instructions to reduce layers
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# Use .dockerignore to exclude unnecessary files
# Copy package files first for better caching
COPY package*.json ./
RUN npm install
COPY . .

# Use multi-stage builds for smaller images
FROM node:16 AS builder
# ... build steps ...
FROM node:16-alpine AS production
COPY --from=builder /app/dist ./dist
```

## Docker Compose

### What is Docker Compose?
Docker Compose is a tool for defining and running multi-container Docker applications using a YAML file.

### Installation
```bash
# Install Docker Compose (Linux)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Docker Compose File Structure

#### Basic Structure (docker-compose.yml)
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/code
    environment:
      - FLASK_ENV=development
    depends_on:
      - redis

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

volumes:
  data:

networks:
  frontend:
  backend:
```

#### Service Configuration Options

##### Build Configuration
```yaml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
      args:
        - VERSION=1.0
        - BUILD_DATE=2023-01-01
    # OR
    build: .
```

##### Image and Container Name
```yaml
services:
  web:
    image: nginx:latest
    container_name: my-nginx
```

##### Ports and Networking
```yaml
services:
  web:
    ports:
      - "8080:80"        # host:container
      - "443:443"
      - "127.0.0.1:8081:80"  # bind to specific interface
    expose:
      - "3000"           # expose to other services only
    networks:
      - frontend
      - backend
```

##### Volumes and Bind Mounts
```yaml
services:
  web:
    volumes:
      - ./app:/usr/src/app          # bind mount
      - data-volume:/var/lib/data   # named volume
      - /host/path:/container/path:ro  # read-only
    tmpfs:
      - /tmp
```

##### Environment Variables
```yaml
services:
  web:
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://db:5432/myapp
    env_file:
      - .env
      - .env.local
```

##### Dependencies and Health Checks
```yaml
services:
  web:
    depends_on:
      - db
      - redis
    # OR with conditions
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

##### Resource Limits
```yaml
services:
  web:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    restart: unless-stopped
```

### Complete Docker Compose Examples

#### LAMP Stack
```yaml
version: '3.8'

services:
  web:
    image: php:8.0-apache
    container_name: php-web
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
    depends_on:
      - db
    networks:
      - lamp-network

  db:
    image: mysql:8.0
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: myapp
      MYSQL_USER: user
      MYSQL_PASSWORD: password
    volumes:
      - db-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
    networks:
      - lamp-network

  phpmyadmin:
    image: phpmyadmin:latest
    container_name: phpmyadmin
    environment:
      PMA_HOST: db
      PMA_PORT: 3306
    ports:
      - "8080:80"
    depends_on:
      - db
    networks:
      - lamp-network

volumes:
  db-data:

networks:
  lamp-network:
    driver: bridge
```

#### Node.js with MongoDB and Redis
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: node-app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/myapp
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./logs:/app/logs
    depends_on:
      - mongo
      - redis
    networks:
      - app-network
    restart: unless-stopped

  mongo:
    image: mongo:5.0
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
      MONGO_INITDB_DATABASE: myapp
    volumes:
      - mongo-data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js
    ports:
      - "27017:27017"
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    container_name: redis-cache
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    networks:
      - app-network

volumes:
  mongo-data:
  redis-data:

networks:
  app-network:
    driver: bridge
```

### Docker Compose Commands

#### Basic Commands
```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# Build and start
docker-compose up --build

# Start specific service
docker-compose up web

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop and remove images
docker-compose down --rmi all
```

#### Service Management
```bash
# View running services
docker-compose ps

# View logs
docker-compose logs
docker-compose logs -f web

# Execute command in service
docker-compose exec web bash

# Scale services
docker-compose up --scale web=3

# Restart services
docker-compose restart
docker-compose restart web
```

#### Build and Images
```bash
# Build services
docker-compose build

# Build without cache
docker-compose build --no-cache

# Pull latest images
docker-compose pull

# Push images to registry
docker-compose push
```

### Environment Files

#### .env File
```bash
# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=secret

# Application configuration
APP_ENV=production
APP_PORT=3000
SECRET_KEY=your-secret-key

# External services
REDIS_URL=redis://localhost:6379
API_KEY=your-api-key
```

#### Using in docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    image: myapp:latest
    ports:
      - "${APP_PORT}:3000"
    environment:
      - NODE_ENV=${APP_ENV}
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
    env_file:
      - .env
```

## Docker Registry

### What is a Docker Registry?
A Docker registry is a storage and distribution system for Docker images. It allows you to store, manage, and distribute Docker images.

### Types of Registries

#### Public Registries
- **Docker Hub**: Default public registry
- **Amazon ECR Public**: AWS public registry
- **Google Container Registry**: Google's public registry
- **GitHub Container Registry**: GitHub's registry

#### Private Registries
- **Docker Hub Private**: Private repositories on Docker Hub
- **Amazon ECR**: AWS private registry
- **Azure Container Registry**: Microsoft's private registry
- **Google Container Registry**: Google's private registry
- **Harbor**: Open-source private registry
- **Self-hosted Registry**: Docker's official registry image

### Docker Hub

#### Authentication
```bash
# Login to Docker Hub
docker login

# Login with username
docker login -u username

# Logout
docker logout
```

#### Image Operations
```bash
# Tag image for Docker Hub
docker tag myapp:latest username/myapp:latest
docker tag myapp:latest username/myapp:v1.0

# Push image to Docker Hub
docker push username/myapp:latest
docker push username/myapp:v1.0

# Pull image from Docker Hub
docker pull username/myapp:latest

# Search for images
docker search nginx
```

### Private Registry Setup

#### Self-hosted Registry
```bash
# Run registry container
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v registry-data:/var/lib/registry \
  registry:2

# With authentication
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v registry-data:/var/lib/registry \
  -v $(pwd)/auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  registry:2
```

#### Using Private Registry
```bash
# Tag for private registry
docker tag myapp:latest localhost:5000/myapp:latest

# Push to private registry
docker push localhost:5000/myapp:latest

# Pull from private registry
docker pull localhost:5000/myapp:latest
```

### Registry Configuration

#### Registry with TLS
```yaml
# docker-compose.yml for secure registry
version: '3.8'

services:
  registry:
    image: registry:2
    ports:
      - "5000:5000"
    environment:
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
      REGISTRY_HTTP_TLS_KEY: /certs/domain.key
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
    volumes:
      - registry-data:/var/lib/registry
      - ./certs:/certs
      - ./auth:/auth

volumes:
  registry-data:
```

#### Registry with UI
```yaml
version: '3.8'

services:
  registry:
    image: registry:2
    ports:
      - "5000:5000"
    volumes:
      - registry-data:/var/lib/registry

  registry-ui:
    image: joxit/docker-registry-ui:latest
    ports:
      - "8080:80"
    environment:
      - REGISTRY_TITLE=My Private Registry
      - REGISTRY_URL=http://registry:5000
    depends_on:
      - registry

volumes:
  registry-data:
```

### Cloud Registry Services

#### Amazon ECR
```bash
# Get login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# Create repository
aws ecr create-repository --repository-name myapp

# Tag and push
docker tag myapp:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:latest
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:latest
```

#### Google Container Registry
```bash
# Configure authentication
gcloud auth configure-docker

# Tag and push
docker tag myapp:latest gcr.io/project-id/myapp:latest
docker push gcr.io/project-id/myapp:latest
```

#### Azure Container Registry
```bash
# Login to ACR
az acr login --name myregistry

# Tag and push
docker tag myapp:latest myregistry.azurecr.io/myapp:latest
docker push myregistry.azurecr.io/myapp:latest
```

## Docker Engine

### What is Docker Engine?
Docker Engine is the core component of Docker that creates and manages containers. It consists of:
- **Docker Daemon** (dockerd): Background service
- **REST API**: Interface for interacting with daemon
- **Docker CLI**: Command-line interface

### Docker Engine Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    Docker Engine                        │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Docker CLI  │  │  REST API   │  │  Docker Daemon  │  │
│  │             │  │             │  │    (dockerd)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                   containerd                            │
├─────────────────────────────────────────────────────────┤
│                     runc                                │
├─────────────────────────────────────────────────────────┤
│                   Host OS Kernel                        │
└─────────────────────────────────────────────────────────┘
```

### Docker Daemon Configuration

#### Daemon Configuration File (/etc/docker/daemon.json)
```json
{
  "data-root": "/var/lib/docker",
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-runtime": "runc",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "registry-mirrors": [
    "https://mirror.gcr.io"
  ],
  "insecure-registries": [
    "localhost:5000"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "mtu": 1500,
  "userland-proxy": false,
  "experimental": false,
  "metrics-addr": "127.0.0.1:9323",
  "api-cors-header": "*"
}
```

#### Daemon Management
```bash
# Start Docker daemon
sudo systemctl start docker

# Stop Docker daemon
sudo systemctl stop docker

# Restart Docker daemon
sudo systemctl restart docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check daemon status
sudo systemctl status docker

# View daemon logs
sudo journalctl -u docker.service

# Reload daemon configuration
sudo systemctl reload docker
```

### Docker Engine Modes

#### Standalone Mode
- Single Docker Engine instance
- Manages containers on single host
- Default mode for development

#### Swarm Mode
- Cluster of Docker Engines
- Built-in orchestration
- High availability and scaling

```bash
# Initialize swarm
docker swarm init

# Join swarm as worker
docker swarm join --token <token> <manager-ip>:2377

# Join swarm as manager
docker swarm join --token <manager-token> <manager-ip>:2377

# List nodes
docker node ls

# Deploy service
docker service create --name web --replicas 3 -p 80:80 nginx
```

### Container Runtime

#### containerd
- High-level container runtime
- Manages container lifecycle
- Image management and storage
- Network and storage interfaces

#### runc
- Low-level container runtime
- OCI (Open Container Initiative) compliant
- Creates and runs containers
- Interfaces directly with kernel

### Docker Engine API

#### REST API Examples
```bash
# List containers
curl --unix-socket /var/run/docker.sock http://localhost/containers/json

# Get container info
curl --unix-socket /var/run/docker.sock http://localhost/containers/mycontainer/json

# Start container
curl -X POST --unix-socket /var/run/docker.sock http://localhost/containers/mycontainer/start

# Create container
curl -X POST --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Image": "nginx", "ExposedPorts": {"80/tcp": {}}}' \
  http://localhost/containers/create
```

#### Using Docker SDK
```python
# Python Docker SDK
import docker

client = docker.from_env()

# List containers
containers = client.containers.list()

# Run container
container = client.containers.run("nginx", detach=True, ports={'80/tcp': 8080})

# Build image
image = client.images.build(path=".", tag="myapp:latest")
```

### Performance Tuning

#### Storage Driver Optimization
```json
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
```

#### Logging Configuration
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

#### Resource Limits
```bash
# Set default ulimits
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

## Docker Storage

### Storage Types

#### 1. Volumes
- Managed by Docker
- Stored in Docker area (/var/lib/docker/volumes/)
- Best for persistent data
- Can be shared between containers

#### 2. Bind Mounts
- Mount host directory/file into container
- Full control over mount point
- Host path must exist
- Good for development

#### 3. tmpfs Mounts
- Stored in host memory
- Not persisted to disk
- Good for temporary data
- Linux only

### Storage Comparison
```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│     Feature     │    Volumes      │  Bind Mounts    │   tmpfs Mounts  │
├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
│ Managed by      │ Docker          │ User            │ Docker          │
│ Host location   │ Docker area     │ Anywhere        │ Memory          │
│ Persistence     │ Yes             │ Yes             │ No              │
│ Performance     │ Good            │ Good            │ Excellent       │
│ Sharing         │ Easy            │ Manual          │ No              │
│ Backup          │ Easy            │ Manual          │ N/A             │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

### Volume Management

#### Volume Commands
```bash
# Create volume
docker volume create myvolume

# List volumes
docker volume ls

# Inspect volume
docker volume inspect myvolume

# Remove volume
docker volume rm myvolume

# Remove unused volumes
docker volume prune

# Remove all volumes
docker volume rm $(docker volume ls -q)
```

#### Using Volumes
```bash
# Run container with named volume
docker run -v myvolume:/data nginx

# Run container with anonymous volume
docker run -v /data nginx

# Multiple volumes
docker run -v vol1:/data1 -v vol2:/data2 nginx

# Read-only volume
docker run -v myvolume:/data:ro nginx
```

#### Volume Drivers
```bash
# Local driver (default)
docker volume create --driver local myvolume

# NFS volume
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume

# CIFS/SMB volume
docker volume create --driver local \
  --opt type=cifs \
  --opt o=username=user,password=pass \
  --opt device=//server/share \
  cifs-volume
```

### Bind Mounts

#### Basic Bind Mount
```bash
# Mount host directory
docker run -v /host/path:/container/path nginx

# Mount current directory
docker run -v $(pwd):/app nginx

# Mount with specific options
docker run -v /host/path:/container/path:ro,Z nginx

# Mount single file
docker run -v /host/file.txt:/container/file.txt nginx
```

#### Bind Mount Options
```bash
# Read-only
docker run -v /host/path:/container/path:ro nginx

# SELinux labels
docker run -v /host/path:/container/path:Z nginx    # Private label
docker run -v /host/path:/container/path:z nginx    # Shared label

# Bind propagation
docker run -v /host/path:/container/path:shared nginx
docker run -v /host/path:/container/path:slave nginx
docker run -v /host/path:/container/path:private nginx
```

### tmpfs Mounts

#### Using tmpfs
```bash
# Mount tmpfs
docker run --tmpfs /tmp nginx

# Mount with options
docker run --tmpfs /tmp:rw,noexec,nosuid,size=100m nginx

# Multiple tmpfs mounts
docker run --tmpfs /tmp --tmpfs /var/tmp nginx
```

### Storage in Docker Compose

#### Volume Configuration
```yaml
version: '3.8'

services:
  web:
    image: nginx
    volumes:
      # Named volume
      - web-data:/var/www/html
      
      # Bind mount
      - ./src:/usr/src/app
      
      # Anonymous volume
      - /var/log/nginx
      
      # Read-only bind mount
      - ./config:/etc/nginx:ro
      
      # tmpfs mount
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 1000000000  # 1GB

  db:
    image: postgres
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp

volumes:
  web-data:
    driver: local
  db-data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=nfs-server,rw
      device: ":/path/to/data"
```

#### External Volumes
```yaml
version: '3.8'

services:
  web:
    image: nginx
    volumes:
      - existing-volume:/data

volumes:
  existing-volume:
    external: true
```

### Storage Drivers

#### Available Drivers
- **overlay2**: Default for most Linux distributions
- **aufs**: Legacy driver for older systems
- **devicemapper**: For CentOS/RHEL 7
- **btrfs**: For Btrfs filesystems
- **zfs**: For ZFS filesystems
- **vfs**: For testing (not for production)

#### Storage Driver Configuration
```json
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true",
    "overlay2.size=20G"
  ]
}
```

#### Check Storage Driver
```bash
# View storage driver info
docker info | grep "Storage Driver"

# Detailed storage info
docker system df
docker system df -v
```

### Data Management

#### Backup and Restore

##### Volume Backup
```bash
# Backup volume to tar file
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/backup.tar.gz -C /data .

# Restore volume from tar file
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/backup.tar.gz -C /data
```

##### Database Backup
```bash
# Backup PostgreSQL
docker exec postgres-container pg_dump -U user dbname > backup.sql

# Restore PostgreSQL
docker exec -i postgres-container psql -U user dbname < backup.sql

# Backup MySQL
docker exec mysql-container mysqldump -u user -p dbname > backup.sql

# Restore MySQL
docker exec -i mysql-container mysql -u user -p dbname < backup.sql
```

#### Data Migration
```bash
# Copy data between volumes
docker run --rm \
  -v source-volume:/source \
  -v target-volume:/target \
  ubuntu cp -r /source/. /target/

# Migrate to new storage driver
docker save $(docker images -q) -o images.tar
# Change storage driver in daemon.json
sudo systemctl restart docker
docker load -i images.tar
```

### Performance Optimization

#### Storage Performance Tips
1. **Use appropriate storage driver**
2. **Optimize volume placement**
3. **Use SSD for Docker root**
4. **Configure proper filesystem**
5. **Monitor disk I/O**

#### Monitoring Storage
```bash
# Check disk usage
docker system df

# Check container sizes
docker ps -s

# Check image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Monitor I/O
iostat -x 1
iotop
```

## Docker Networking

### Network Types

#### 1. Bridge Network (Default)
- Default network for containers
- Isolated from host network
- Containers can communicate with each other
- NAT to access external networks

#### 2. Host Network
- Container uses host's network stack
- No network isolation
- Best performance
- Port conflicts possible

#### 3. None Network
- No network access
- Complete isolation
- Good for security-sensitive applications

#### 4. Overlay Network
- Multi-host networking
- Used in Docker Swarm
- Encrypted by default

#### 5. Macvlan Network
- Assign MAC address to container
- Container appears as physical device
- Direct connection to physical network

### Network Commands

#### Basic Network Operations
```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge

# Create network
docker network create mynetwork

# Remove network
docker network rm mynetwork

# Remove unused networks
docker network prune

# Connect container to network
docker network connect mynetwork mycontainer

# Disconnect container from network
docker network disconnect mynetwork mycontainer
```

### Bridge Networks

#### Default Bridge
```bash
# Run container on default bridge
docker run -d --name web nginx

# Check container IP
docker inspect web | grep IPAddress
```

#### Custom Bridge
```bash
# Create custom bridge network
docker network create --driver bridge mybridge

# Run containers on custom bridge
docker run -d --name web1 --network mybridge nginx
docker run -d --name web2 --network mybridge nginx

# Containers can communicate by name
docker exec web1 ping web2
```

#### Bridge Network Configuration
```bash
# Create bridge with custom subnet
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  mybridge

# Create bridge with options
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.name=mybr0 \
  --opt com.docker.network.driver.mtu=1500 \
  mybridge
```

### Host Network

#### Using Host Network
```bash
# Run container with host network
docker run -d --network host nginx

# Container uses host's network interface
# No port mapping needed
# Direct access to host ports
```

### Overlay Networks

#### Swarm Overlay Network
```bash
# Initialize swarm (if not already done)
docker swarm init

# Create overlay network
docker network create --driver overlay myoverlay

# Create service using overlay network
docker service create \
  --name web \
  --network myoverlay \
  --replicas 3 \
  nginx
```

#### Standalone Overlay Network
```bash
# Create attachable overlay network
docker network create \
  --driver overlay \
  --attachable \
  myoverlay

# Run containers on overlay network
docker run -d --name web1 --network myoverlay nginx
docker run -d --name web2 --network myoverlay nginx
```

### Macvlan Networks

#### Macvlan Configuration
```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan-net

# Run container with macvlan
docker run -d \
  --name web \
  --network macvlan-net \
  --ip=192.168.1.100 \
  nginx
```

### Network Configuration in Docker Compose

#### Basic Networking
```yaml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - frontend
      - backend

  api:
    image: myapi
    networks:
      - backend

  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

#### Advanced Network Configuration
```yaml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      frontend:
        ipv4_address: 172.20.0.10
      backend:
        aliases:
          - webserver

networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1

  backend:
    driver: overlay
    attachable: true
    driver_opts:
      encrypted: "true"

  external-net:
    external: true
```

### Port Publishing

#### Port Mapping Options
```bash
# Map container port to host port
docker run -p 8080:80 nginx

# Map to specific host interface
docker run -p 127.0.0.1:8080:80 nginx

# Map to random host port
docker run -P nginx

# Map multiple ports
docker run -p 8080:80 -p 8443:443 nginx

# Map UDP port
docker run -p 8080:80/udp nginx

# Map port range
docker run -p 8080-8090:8080-8090 nginx
```

#### Port Publishing in Compose
```yaml
version: '3.8'

services:
  web:
    image: nginx
    ports:
      - "8080:80"                    # host:container
      - "127.0.0.1:8081:80"         # interface:host:container
      - "8443:443"
      - "8080-8090:8080-8090"       # port range
    expose:
      - "3000"                       # expose to other services only
```

### Service Discovery

#### DNS Resolution
```bash
# Containers on same network can resolve by name
docker network create mynet
docker run -d --name web --network mynet nginx
docker run -d --name app --network mynet myapp

# From app container, can access web container
docker exec app curl http://web
```

#### Service Discovery in Compose
```yaml
version: '3.8'

services:
  web:
    image: nginx
    
  app:
    image: myapp
    environment:
      - WEB_URL=http://web  # Can use service name as hostname
    depends_on:
      - web
```

### Load Balancing

#### Built-in Load Balancing
```bash
# Docker Swarm provides built-in load balancing
docker service create \
  --name web \
  --replicas 3 \
  --publish 80:80 \
  nginx

# Requests to port 80 are load balanced across replicas
```

#### External Load Balancer
```yaml
version: '3.8'

services:
  nginx:
    image: nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app

  app:
    image: myapp
    deploy:
      replicas: 3
    expose:
      - "3000"
```

### Network Security

#### Network Isolation
```bash
# Create isolated network
docker network create --internal backend

# Containers on internal network cannot access external networks
docker run -d --name db --network backend postgres
```

#### Network Encryption
```bash
# Create encrypted overlay network
docker network create \
  --driver overlay \
  --opt encrypted \
  secure-network
```

#### Firewall Rules
```bash
# Docker automatically creates iptables rules
# View Docker-related rules
sudo iptables -L DOCKER
sudo iptables -L DOCKER-USER

# Add custom rules to DOCKER-USER chain
sudo iptables -I DOCKER-USER -s 192.168.1.0/24 -j DROP
```

### Network Troubleshooting

#### Debugging Network Issues
```bash
# Check container network configuration
docker exec container ip addr show
docker exec container ip route show

# Test connectivity
docker exec container ping google.com
docker exec container telnet host port

# Check DNS resolution
docker exec container nslookup hostname
docker exec container dig hostname

# View network traffic
docker exec container tcpdump -i eth0

# Check port binding
docker port container
netstat -tlnp | grep docker
```

#### Common Network Problems

1. **Port conflicts**
   ```bash
   # Check what's using a port
   sudo netstat -tlnp | grep :8080
   sudo lsof -i :8080
   ```

2. **DNS resolution issues**
   ```bash
   # Check container DNS settings
   docker exec container cat /etc/resolv.conf
   
   # Test DNS resolution
   docker exec container nslookup google.com
   ```

3. **Network connectivity**
   ```bash
   # Check routing
   docker exec container ip route show
   
   # Test connectivity
   docker exec container ping 8.8.8.8
   ```

### Performance Optimization

#### Network Performance Tips
1. **Use host networking for high-performance applications**
2. **Optimize MTU settings**
3. **Use appropriate network driver**
4. **Monitor network metrics**
5. **Avoid unnecessary port mappings**

#### Monitoring Network Performance
```bash
# Monitor network usage
docker stats

# Check network interface statistics
cat /proc/net/dev

# Monitor with tools
iftop
nethogs
iperf3
```

## Best Practices

### Image Best Practices

#### 1. Use Official Base Images
```dockerfile
# Good: Use official images
FROM node:16-alpine
FROM python:3.9-slim

# Avoid: Unknown or untrusted images
FROM random-user/custom-node
```

#### 2. Use Specific Tags
```dockerfile
# Good: Specific version
FROM node:16.14.2-alpine

# Avoid: Latest tag
FROM node:latest
```

#### 3. Minimize Image Layers
```dockerfile
# Good: Combine RUN instructions
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim && \
    rm -rf /var/lib/apt/lists/*

# Avoid: Multiple RUN instructions
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y vim
```

#### 4. Use Multi-stage Builds
```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "index.js"]
```

#### 5. Use .dockerignore
```
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
```

### Security Best Practices

#### 1. Run as Non-root User
```dockerfile
# Create and use non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Or use numeric UID
USER 1001
```

#### 2. Use Read-only Filesystems
```bash
# Run container with read-only filesystem
docker run --read-only --tmpfs /tmp nginx
```

#### 3. Limit Resources
```bash
# Limit memory and CPU
docker run -m 512m --cpus="1.0" nginx
```

#### 4. Use Secrets Management
```bash
# Use Docker secrets (Swarm mode)
echo "mysecret" | docker secret create db_password -

# Use environment variables for non-sensitive config only
docker run -e NODE_ENV=production myapp
```

#### 5. Scan Images for Vulnerabilities
```bash
# Use Docker Scout (built-in)
docker scout cves myimage:latest

# Use third-party tools
trivy image myimage:latest
snyk container test myimage:latest
```

### Performance Best Practices

#### 1. Optimize Image Size
```dockerfile
# Use alpine variants
FROM node:16-alpine

# Remove unnecessary packages
RUN apk add --no-cache git && \
    # ... build steps ... && \
    apk del git

# Use multi-stage builds
FROM node:16 AS builder
# ... build steps ...
FROM node:16-alpine
COPY --from=builder /app/dist ./dist
```

#### 2. Leverage Build Cache
```dockerfile
# Copy package files first
COPY package*.json ./
RUN npm install

# Copy source code last
COPY . .
```

#### 3. Use Appropriate Storage Drivers
```json
{
  "storage-driver": "overlay2"
}
```

#### 4. Monitor Resource Usage
```bash
# Monitor container resources
docker stats

# Set resource limits
docker run -m 512m --cpus="1.0" nginx
```

### Development Best Practices

#### 1. Use Docker Compose for Development
```yaml
version: '3.8'

services:
  app:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
```

#### 2. Use Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

#### 3. Implement Graceful Shutdown
```javascript
// Node.js example
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    process.exit(0);
  });
});
```

#### 4. Use Init System for Multiple Processes
```dockerfile
# Use tini as init system
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]
```

### Production Best Practices

#### 1. Use Orchestration
- **Docker Swarm**: Built-in orchestration
- **Kubernetes**: Advanced orchestration
- **Amazon ECS**: AWS container service
- **Azure Container Instances**: Azure container service

#### 2. Implement Logging
```dockerfile
# Configure logging driver
docker run --log-driver=json-file --log-opt max-size=10m nginx
```

#### 3. Use Load Balancers
```yaml
version: '3.8'

services:
  nginx:
    image: nginx
    ports:
      - "80:80"
    depends_on:
      - app

  app:
    image: myapp
    deploy:
      replicas: 3
```

#### 4. Implement Monitoring
```yaml
version: '3.8'

services:
  app:
    image: myapp
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=3000"
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Container Won't Start
```bash
# Check container logs
docker logs container-name

# Check container configuration
docker inspect container-name

# Run container interactively
docker run -it image-name /bin/bash
```

#### 2. Port Already in Use
```bash
# Find what's using the port
sudo netstat -tlnp | grep :8080
sudo lsof -i :8080

# Kill process using port
sudo kill -9 PID

# Use different port
docker run -p 8081:80 nginx
```

#### 3. Out of Disk Space
```bash
# Check disk usage
docker system df

# Clean up unused resources
docker system prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune
```

#### 4. Permission Denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Restart session or run
newgrp docker

# Check file permissions
ls -la /var/run/docker.sock
```

#### 5. Network Issues
```bash
# Check container network
docker network ls
docker network inspect bridge

# Test connectivity
docker exec container ping google.com

# Check DNS
docker exec container nslookup google.com
```

### Debugging Commands

#### Container Debugging
```bash
# Enter running container
docker exec -it container-name /bin/bash

# Check container processes
docker exec container-name ps aux

# Check container environment
docker exec container-name env

# Check container filesystem
docker exec container-name df -h
```

#### System Debugging
```bash
# Check Docker daemon status
sudo systemctl status docker

# View Docker daemon logs
sudo journalctl -u docker.service

# Check Docker version and info
docker version
docker info

# Check system resources
docker system df
docker system events
```

### Performance Troubleshooting

#### Resource Usage
```bash
# Monitor container resources
docker stats

# Check system resources
top
htop
free -h
df -h
```

#### Network Performance
```bash
# Test network speed
docker run --rm -it networkstatic/iperf3 -c iperf.he.net

# Monitor network traffic
docker exec container-name netstat -i
```

#### Storage Performance
```bash
# Check I/O statistics
iostat -x 1

# Monitor disk usage
docker system df -v
```

This comprehensive Docker guide covers everything from basic concepts to advanced topics including Docker Engine, storage, and networking. Each section provides practical examples and best practices for real-world usage.