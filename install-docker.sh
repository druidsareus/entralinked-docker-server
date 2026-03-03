#!/bin/bash

# Entralinked Docker VPS Deployment Script
# Debian 13 / Ubuntu 24.04+
# Run with: bash deploy.sh

set -e

echo "=== Entralinked Docker VPS Deployment ==="
echo "Installing Docker and Docker Compose..."

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group (optional, for non-root usage)
sudo usermod -aG docker "$USER"
echo "Note: You may need to log out and back in for docker group to take effect"

# Verify Docker installation
echo "Docker version:"
docker --version
docker compose version

echo ""
echo "=== Deployment Complete ==="
echo "You can now run: docker compose up -d"
