# Docker Learning Notes

## Introduction

During my containerization journey, I've found Docker to be one of the most powerful tools for application deployment. Here's what I've learned about Docker and how to use it effectively.

## What is Docker?

Docker is basically a way to package your application with everything it needs to run - code, runtime, system tools, libraries, and settings. Think of it like shipping containers for software.

### Why I Use Docker

After working with traditional deployments, Docker solved these problems for me:
- "It works on my machine" syndrome
- Environment inconsistencies between dev/staging/prod
- Complex dependency management
- Slow deployment processes

### Containers vs VMs

I used to rely heavily on VMs, but containers changed everything:

**Virtual Machines:**
- Each VM needs its own OS
- Heavy resource usage
- Slower startup times
- Good isolation but expensive

**Containers:**
- Share the host OS kernel
- Lightweight and fast
- Quick startup (seconds vs minutes)
- Efficient resource usage

## Getting Started with Docker

### Installation on Ubuntu

Here's how I set up Docker on my Ubuntu systems:

```bash
# Remove old versions if any
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update and install prerequisites
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add yourself to docker group (logout/login required)
sudo usermod -aG docker $USER
```

### First Steps

```bash
# Test installation
docker run hello-world

# Check version
docker --version

# See system info
docker info
```

## Working with Images

### Understanding Images

Images are like templates or blueprints. I think of them as read-only snapshots that contain everything needed to run an application.

### Basic Image Commands

```bash
# See what images you have
docker images

# Download an image
docker pull ubuntu:20.04
docker pull nginx:latest

# Remove an image
docker rmi nginx:latest

# Clean up unused images
docker image prune
```

### Building Your Own Images

I always start with a Dockerfile. Here's a simple example I use for Node.js apps:

```dockerfile
FROM node:16-alpine

WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

Build it:
```bash
docker build -t my-node-app .
```

## Container Management

### Running Containers

```bash
# Basic run
docker run nginx

# Run in background
docker run -d nginx

# Run with custom name
docker run -d --name my-web nginx

# Run with port mapping
docker run -d -p 8080:80 nginx

# Run interactively
docker run -it ubuntu bash
```

### Managing Running Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop my-web

# Start a stopped container
docker start my-web

# Remove a container
docker rm my-web

# Remove running container (force)
docker rm -f my-web
```

### Useful Container Operations

```bash
# Execute commands in running container
docker exec -it my-web bash

# View logs
docker logs my-web
docker logs -f my-web  # follow logs

# Copy files
docker cp file.txt my-web:/tmp/
docker cp my-web:/tmp/file.txt ./

# Check resource usage
docker stats
```

## Docker Run Deep Dive

The `docker run` command has tons of options. Here are the ones I use most:

### Port Mapping
```bash
# Map port 8080 on host to port 80 in container
docker run -p 8080:80 nginx

# Map to specific interface
docker run -p 127.0.0.1:8080:80 nginx

# Let Docker choose random port
docker run -P nginx
```

### Volume Mounting
```bash
# Mount host directory
docker run -v /home/user/data:/app/data nginx

# Create named volume
docker run -v mydata:/app/data nginx

# Read-only mount
docker run -v /host/config:/app/config:ro nginx
```

### Environment Variables
```bash
# Set environment variables
docker run -e NODE_ENV=production -e PORT=3000 my-app

# Load from file
docker run --env-file .env my-app
```

### Resource Limits
```bash
# Limit memory to 512MB
docker run -m 512m nginx

# Limit CPU usage
docker run --cpus="1.5" nginx

# Both memory and CPU
docker run -m 1g --cpus="2" nginx
```

## Dockerfile Best Practices

From my experience, here are the key things to remember:

### Use Specific Tags
```dockerfile
# Good
FROM node:16.14.2-alpine

# Avoid
FROM node:latest
```

### Minimize Layers
```dockerfile
# Good - single RUN instruction
RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

# Avoid - multiple RUN instructions
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
```

### Multi-stage Builds
This technique has saved me tons of space:

```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/index.js"]
```

### Security Considerations
```dockerfile
# Don't run as root
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Use COPY instead of ADD
COPY . .

# Set proper permissions
RUN chown -R nextjs:nodejs /app
```

## Docker Compose

For multi-container applications, Docker Compose is a lifesaver. I use it for local development and testing.

### Basic docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

### Compose Commands I Use Daily

```bash
# Start everything
docker-compose up

# Start in background
docker-compose up -d

# Build and start
docker-compose up --build

# Stop everything
docker-compose down

# View logs
docker-compose logs -f

# Execute command in service
docker-compose exec web bash

# Scale a service
docker-compose up --scale web=3
```

### Real-world Example

Here's a setup I use for a typical web application:

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app

  app:
    build: .
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db_data:/var/lib/postgresql/data

  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data

volumes:
  db_data:
  redis_data:
```

## Docker Registry and Image Management

### Working with Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag your image
docker tag my-app:latest username/my-app:latest

# Push to Docker Hub
docker push username/my-app:latest

# Pull someone else's image
docker pull username/their-app:latest
```

### Private Registry

Sometimes I need to set up a private registry:

```bash
# Run a local registry
docker run -d -p 5000:5000 --name registry registry:2

# Tag for private registry
docker tag my-app localhost:5000/my-app

# Push to private registry
docker push localhost:5000/my-app
```

## Storage in Docker

### Volume Types

I work with three types of storage:

1. **Volumes** (managed by Docker)
2. **Bind mounts** (host filesystem)
3. **tmpfs mounts** (memory)

### Volume Management

```bash
# Create a volume
docker volume create my-data

# List volumes
docker volume ls

# Inspect volume
docker volume inspect my-data

# Remove volume
docker volume rm my-data

# Clean up unused volumes
docker volume prune
```

### Using Volumes

```bash
# Named volume
docker run -v my-data:/app/data nginx

# Bind mount
docker run -v /host/path:/container/path nginx

# tmpfs (temporary filesystem in memory)
docker run --tmpfs /tmp nginx
```

## Docker Networking

### Network Types

Docker provides several network drivers:

- **bridge**: Default network for containers
- **host**: Use host's network directly
- **none**: No networking
- **overlay**: Multi-host networking (Swarm)

### Network Commands

```bash
# List networks
docker network ls

# Create custom network
docker network create my-network

# Run container on specific network
docker run --network my-network nginx

# Connect running container to network
docker network connect my-network my-container
```

### Custom Bridge Network

I often create custom networks for better container communication:

```bash
# Create network
docker network create --driver bridge my-app-network

# Run containers on same network
docker run -d --name web --network my-app-network nginx
docker run -d --name api --network my-app-network my-api

# Now they can communicate by name
docker exec web ping api
```

## Troubleshooting Common Issues

### Container Won't Start

```bash
# Check logs
docker logs container-name

# Run interactively to debug
docker run -it image-name /bin/bash

# Check if port is already in use
sudo netstat -tlnp | grep :8080
```

### Out of Space

```bash
# See what's taking space
docker system df

# Clean up everything unused
docker system prune -a

# Remove specific things
docker container prune  # stopped containers
docker image prune      # unused images
docker volume prune     # unused volumes
```

### Permission Issues

```bash
# Make sure you're in docker group
groups $USER

# If not, add yourself
sudo usermod -aG docker $USER
# Then logout and login again
```

### Network Problems

```bash
# Check container network settings
docker exec container-name ip addr

# Test connectivity
docker exec container-name ping google.com

# Check DNS
docker exec container-name nslookup google.com
```

## Performance Tips

### Image Optimization

1. Use alpine-based images when possible
2. Use multi-stage builds
3. Minimize layers
4. Use .dockerignore file
5. Don't install unnecessary packages

### Runtime Optimization

```bash
# Set resource limits
docker run -m 512m --cpus="1.0" nginx

# Use appropriate restart policies
docker run --restart=unless-stopped nginx

# Monitor resource usage
docker stats
```

### Development Workflow

For development, I use this pattern:

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
```

```dockerfile
# Dockerfile.dev
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

# Don't copy source code - use volume mount instead

CMD ["npm", "run", "dev"]
```

## Security Best Practices

### Image Security

- Use official images when possible
- Keep images updated
- Scan for vulnerabilities
- Don't store secrets in images

### Runtime Security

```bash
# Run as non-root user
docker run --user 1000:1000 nginx

# Use read-only filesystem
docker run --read-only nginx

# Drop capabilities
docker run --cap-drop=ALL nginx

# Use security profiles
docker run --security-opt=no-new-privileges nginx
```

## Monitoring and Logging

### Basic Monitoring

```bash
# Real-time stats
docker stats

# Container processes
docker exec container-name ps aux

# System events
docker events
```

### Logging

```bash
# View logs
docker logs container-name

# Follow logs
docker logs -f container-name

# Logs with timestamps
docker logs -t container-name

# Last N lines
docker logs --tail 50 container-name
```

## Useful Commands Reference

### Daily Commands
```bash
# Quick cleanup
docker system prune

# See everything
docker ps -a && docker images && docker volume ls

# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)
```

### Debugging Commands
```bash
# Enter running container
docker exec -it container-name bash

# Copy files
docker cp container-name:/path/file ./file

# Check container config
docker inspect container-name

# See port mappings
docker port container-name
```

This guide covers most of what I use Docker for on a daily basis. The key is to start simple and gradually add complexity as you get comfortable with the basics.