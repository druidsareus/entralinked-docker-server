# How to Deploy to Your Debian 13 VPS

## FASTEST METHOD: One-Liner Deployment

SSH into your VPS and copy-paste this command:

```bash
bash <(curl -s https://raw.githubusercontent.com/kuroppoi/entralinked/main/quick-deploy.sh) YOUR_VPS_IP
```

**Example:**
```bash
bash <(curl -s https://raw.githubusercontent.com/kuroppoi/entralinked/main/quick-deploy.sh) 187.124.81.115
```

Replace `187.124.81.115` with your actual VPS IP.

**That's it!** Wait 5 minutes and your server is running.

---

## ALTERNATIVE 1: Transfer Files from Local Machine

If the one-liner doesn't work, transfer files manually:

### On your local machine:

```bash
# Create a directory with the files
mkdir ~/entralinked-vps
cd ~/entralinked-vps

# Create the files (or copy from your working directory)
# Dockerfile, docker-compose.yml, config.json, .dockerignore

# Transfer to VPS
scp Dockerfile root@YOUR_VPS_IP:~/entralinked-vps/
scp docker-compose.yml root@YOUR_VPS_IP:~/entralinked-vps/
scp config.json root@YOUR_VPS_IP:~/entralinked-vps/
scp .dockerignore root@YOUR_VPS_IP:~/entralinked-vps/
```

### On your VPS:

```bash
ssh root@YOUR_VPS_IP

# Install Docker
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# Build and start
cd ~/entralinked-vps
docker compose build
docker compose up -d

# Check status
docker compose logs --tail 50
```

---

## ALTERNATIVE 2: Recreate Files on VPS

If file transfer is giving issues, SSH to VPS and create files directly:

```bash
ssh root@YOUR_VPS_IP

# Install Docker
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker

# Create project directory
mkdir -p ~/entralinked-vps
cd ~/entralinked-vps

# Create Dockerfile (copy entire block)
cat > Dockerfile << 'EOF'
FROM eclipse-temurin:17-jre

WORKDIR /app

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

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

# Create docker-compose.yml
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

# Create config.json (EDIT YOUR_VPS_IP!)
cat > config.json << 'EOF'
{
  "hostName": "YOUR_VPS_IP",
  "clearPlayerDreamInfoOnWake": true,
  "allowOverwritingPlayerDreamInfo": false,
  "allowPlayerGameVersionMismatch": false,
  "allowWfcRegistrationThroughLogin": true
}
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
data
config.json
.git
.gradle
build
*.log
EOF

# Create data directory
mkdir -p data

# Build and start
docker compose build
docker compose up -d

# Verify
sleep 5
docker compose logs --tail 50
```

---

## VERIFY DEPLOYMENT

After any method, verify it's working:

```bash
# Check container is running
docker compose ps

# Check all ports listening
sudo ss -tlnup | grep -E ':(80|443|29900|53)'

# Test HTTP
curl http://localhost/
# Should return: Test

# View logs
docker compose logs --tail 100
```

---

## WHAT SHOULD YOU SEE

When successful, logs will show:

```
entralinked  | 2026-03-03 09:39:53.879  INFO : Startup complete! Took a total of 588 milliseconds
entralinked  | 2026-03-03 09:39:53.879  INFO : Configure your DS to use the following DNS server: YOUR_VPS_IP
```

And ports should show:

```
tcp    LISTEN  0.0.0.0:80      (java)
tcp    LISTEN  0.0.0.0:443     (java)
tcp    LISTEN  0.0.0.0:29900   (java)
udp    LISTEN  0.0.0.0:53      (java)
```

---

## CONFIGURE NINTENDO DS

1. Power on DS
2. Settings → Wifi Settings
3. Edit connection
4. Set DNS Server: **YOUR_VPS_IP** (e.g., 187.124.81.115)
5. Test connection
6. Open Pokémon game
7. Access WiFi features

---

## TROUBLESHOOTING

**Docker not installed:**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
```

**Container won't start:**
```bash
docker compose logs
docker compose build --no-cache
docker compose down -v
docker compose up -d
```

**Ports in use:**
```bash
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :29900
sudo lsof -i :53
```

**Permission denied:**
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

---

## KEEP IT RUNNING

Make sure the container restarts after reboot:

```bash
# Already configured in docker-compose.yml
# But verify with:
docker compose ps

# Should show "restart: unless-stopped"
```

---

## DONE!

Your Entralinked server is now running and ready for Nintendo DS WiFi connections!

Questions? Check the full guides:
- COPY_PASTE_COMMANDS.md
- VPS_DEPLOYMENT.md
- DEPLOY.md
