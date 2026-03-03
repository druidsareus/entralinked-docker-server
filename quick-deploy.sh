#!/bin/bash

# Quick Deploy Script for Entralinked on Debian 13 VPS
# Usage: bash quick-deploy.sh YOUR_VPS_IP
# Example: bash quick-deploy.sh 187.124.81.115

set -e

if [ $# -eq 0 ]; then
    echo "Usage: bash quick-deploy.sh YOUR_VPS_IP"
    echo "Example: bash quick-deploy.sh 187.124.81.115"
    exit 1
fi

VPS_IP=$1

echo "=========================================="
echo "Entralinked Quick Deployment"
echo "VPS IP: $VPS_IP"
echo "=========================================="
echo ""

# Step 1: Update system
echo "[1/6] Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq

# Step 2: Install Docker
echo "[2/6] Installing Docker..."
sudo apt-get install -y -qq docker.io docker-compose

# Step 3: Start Docker
echo "[3/6] Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Step 4: Create project directory
echo "[4/6] Creating project directory..."
mkdir -p ~/entralinked-vps
cd ~/entralinked-vps

# Step 5: Create configuration files
echo "[5/6] Creating configuration files..."

cat > Dockerfile << 'EOF'
FROM eclipse-temurin:17-jre

WORKDIR /app

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download the latest release
RUN curl -L -o entralinked-release.zip \
  "https://github.com/kuroppoi/entralinked/releases/download/v1.4.1/entralinked.%2BPCN.Skins.zip" && \
  unzip -q entralinked-release.zip && \
  cp entralinked/entralinked.jar . && \
  rm -rf entralinked entralinked-release.zip

EXPOSE 80 443 29900 53/udp

CMD ["java", \
     "-Djdk.tls.server.protocols=TLSv1,TLSv1.1,TLSv1.2,TLSv1.3", \
     "-Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2,TLSv1.3", \
     "-Djdk.tls.disabledAlgorithms=", \
     "-jar", "/app/entralinked.jar", "disablegui"]
EOF

cat > docker-compose.yml << EOF
services:
  entralinked:
    build: .
    container_name: entralinked
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "29900:29900"
      - "53:53/udp"
    volumes:
      - ./config.json:/app/config.json
      - ./data:/app/data
    environment:
      JAVA_OPTS: "-Xmx512m"
EOF

cat > config.json << EOF
{
  "hostName": "$VPS_IP",
  "clearPlayerDreamInfoOnWake": true,
  "allowOverwritingPlayerDreamInfo": false,
  "allowPlayerGameVersionMismatch": false,
  "allowWfcRegistrationThroughLogin": true
}
EOF

cat > .dockerignore << 'EOF'
data
config.json
.git
.gradle
build
*.log
EOF

mkdir -p data

# Step 6: Build and start
echo "[6/6] Building and starting Entralinked..."
docker compose build -q
docker compose up -d

# Wait for startup
sleep 3

# Verify
echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Server Details:"
echo "  VPS IP: $VPS_IP"
echo "  Project: ~/entralinked-vps"
echo ""
echo "Configure Nintendo DS:"
echo "  DNS Server: $VPS_IP"
echo ""
echo "Useful Commands:"
echo "  cd ~/entralinked-vps"
echo "  docker compose logs -f          # View live logs"
echo "  docker compose logs --tail 100  # View last 100 lines"
echo "  docker compose restart          # Restart server"
echo "  docker compose stop             # Stop server"
echo ""
echo "Testing:"
echo "  curl http://$VPS_IP/             # Test HTTP"
echo "  dig @$VPS_IP                     # Test DNS"
echo ""

# Show status
echo "Container Status:"
docker compose ps

echo ""
echo "Recent Logs:"
docker compose logs --tail 20
