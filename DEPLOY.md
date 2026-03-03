# Entralinked Docker Deployment Guide - Debian 13 VPS

## Prerequisites

You need:
- Debian 13 VPS (or Ubuntu 24.04+)
- Root or sudo access
- Your VPS IP address (replace `187.124.81.115` with your actual IP)

## Step 1: Connect to Your VPS

```bash
ssh root@your-vps-ip
# or if using a specific user:
ssh user@your-vps-ip
```

## Step 2: Install Docker and Docker Compose

### Option A: Automated (Recommended)

```bash
# Clone or download the deployment files
git clone https://github.com/kuroppoi/entralinked.git
cd entralinked

# Make the install script executable
chmod +x install-docker.sh

# Run the installation
bash install-docker.sh
```

### Option B: Manual Installation

```bash
# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# (Optional) Add your user to docker group to avoid needing sudo
sudo usermod -aG docker $USER
# Log out and back in for this to take effect
```

## Step 3: Set Up Entralinked

### Create project directory

```bash
mkdir ~/entralinked-vps
cd ~/entralinked-vps
```

### Copy the deployment files

You have two options:

**Option A: Transfer files from your local machine**

On your local machine:
```bash
scp Dockerfile root@your-vps-ip:~/entralinked-vps/
scp docker-compose.yml root@your-vps-ip:~/entralinked-vps/
scp config.json root@your-vps-ip:~/entralinked-vps/
scp .dockerignore root@your-vps-ip:~/entralinked-vps/
```

**Option B: Create files on the VPS**

SSH into your VPS and create each file:

```bash
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
```

```bash
cat > docker-compose.yml << 'EOF'
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
```

```bash
cat > config.json << 'EOF'
{
  "hostName": "YOUR_VPS_IP_HERE",
  "clearPlayerDreamInfoOnWake": true,
  "allowOverwritingPlayerDreamInfo": false,
  "allowPlayerGameVersionMismatch": false,
  "allowWfcRegistrationThroughLogin": true
}
EOF
```

Replace `YOUR_VPS_IP_HERE` with your actual VPS IP address.

```bash
cat > .dockerignore << 'EOF'
data
config.json
.git
.gradle
build
*.log
EOF
```

### Create data directory

```bash
mkdir -p data
```

## Step 4: Build the Docker Image

```bash
cd ~/entralinked-vps

# Build the image (this downloads the JAR and builds the container)
docker compose build

# This will take 2-3 minutes on first run
```

## Step 5: Start the Server

```bash
# Start the container in the background
docker compose up -d

# Wait a few seconds for it to start
sleep 5

# View the logs to confirm it started
docker compose logs --tail 50
```

You should see logs like:
```
entralinked  | 2026-03-03 09:39:53.879  INFO ... : Configure your DS to use the following DNS server: YOUR_VPS_IP
```

## Step 6: Verify All Ports are Running

```bash
# Check listening ports
sudo ss -tlnup | grep -E ':(80|443|29900|53)'

# Or use netstat
sudo netstat -tlnup | grep -E ':(80|443|29900|53)'
```

Expected output:
```
tcp    LISTEN  0.0.0.0:80      (entralinked)
tcp    LISTEN  0.0.0.0:443     (entralinked)
tcp    LISTEN  0.0.0.0:29900   (entralinked)
udp    LISTEN  0.0.0.0:53      (entralinked)
```

## Step 7: Test the Server

### Test HTTP endpoint
```bash
curl http://localhost/
# Should return: Test

curl http://localhost/dashboard/profile.html | head -20
# Should return HTML content
```

### Test DNS
```bash
# From another machine or using dig
dig @your-vps-ip +short
```

### Test GameSpy port
```bash
# Check if port 29900 responds
telnet localhost 29900
# Should connect
```

## Step 8: Configure Firewall (If Needed)

If your VPS has a firewall, allow the required ports:

```bash
# For UFW (Ubuntu/Debian default)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 29900/tcp
sudo ufw allow 53/udp

# Check rules
sudo ufw status
```

## Managing the Server

### View logs
```bash
# Real-time logs
docker compose logs -f

# Last 100 lines
docker compose logs --tail 100

# Specific service
docker compose logs entralinked
```

### Restart the server
```bash
docker compose restart
```

### Stop the server
```bash
docker compose stop
```

### Start the server
```bash
docker compose start
```

### Remove everything (careful!)
```bash
docker compose down -v
```

## Configure Your Nintendo DS

1. Go to DS Wifi Settings
2. Configure connection with these settings:
   - DNS: `YOUR_VPS_IP` (e.g., 187.124.81.115)
   - Leave everything else auto
3. Connect to WiFi
4. Open Pokémon game
5. Access WiFi features (Dream World, GTS, Mystery Gift, etc.)

## Troubleshooting

### Container won't start
```bash
# Check detailed logs
docker compose logs

# Rebuild the image
docker compose build --no-cache

# Remove old container
docker compose down -v
docker compose up -d
```

### Ports in use
```bash
# Check what's using port 80
sudo lsof -i :80

# If another service is using it, either:
# 1. Stop that service
# 2. Change the port mapping in docker-compose.yml
```

### Can't connect from DS
1. Verify DNS is correctly set on DS
2. Check that firewall allows ports 80, 443, 29900, 53
3. Verify config.json has correct hostName (your VPS IP)
4. Restart: `docker compose restart`

### Out of disk space
```bash
# Check disk usage
df -h

# Clean up Docker images/containers
docker system prune -a
```

## Production Recommendations

1. **Use a valid SSL certificate** instead of self-signed
   - Install certbot: `sudo apt-get install certbot`
   - Use Let's Encrypt for free certificates

2. **Monitor the container**
   - Set up log rotation
   - Monitor disk usage

3. **Backup data regularly**
   ```bash
   tar -czf entralinked-backup-$(date +%Y%m%d).tar.gz data/
   ```

4. **Update DNS records** if you have a domain:
   - Point your domain to your VPS IP
   - Configure in config.json

## Update Entralinked

To update to a newer version:

```bash
cd ~/entralinked-vps

# Stop the current container
docker compose down

# Rebuild the image (pulls latest version)
docker compose build --no-cache

# Start again
docker compose up -d
```

## Need Help?

Check logs:
```bash
docker compose logs --tail 200
```

Verify container is running:
```bash
docker ps
```

For Entralinked-specific issues:
- GitHub: https://github.com/kuroppoi/entralinked
- Issues: https://github.com/kuroppoi/entralinked/issues
