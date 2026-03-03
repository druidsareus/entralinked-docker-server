# Deployment to Debian 13 VPS - Quick Start

## TL;DR (Fastest Way)

On your VPS, run:

```bash
bash <(curl -s https://raw.githubusercontent.com/kuroppoi/entralinked/main/quick-deploy.sh) YOUR_VPS_IP
```

Replace `YOUR_VPS_IP` with your actual VPS IP (e.g., `187.124.81.115`).

That's it. Server will be running in ~5 minutes.

---

## Step-by-Step Manual Deployment

### 1. SSH into Your VPS

```bash
ssh root@YOUR_VPS_IP
```

### 2. Install Docker (Copy & Paste)

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### 3. Create Project Directory

```bash
mkdir -p ~/entralinked-vps && cd ~/entralinked-vps
```

### 4. Create Dockerfile

```bash
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
```

### 5. Create docker-compose.yml

Replace `187.124.81.115` with your VPS IP:

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

### 6. Create config.json

Replace `YOUR_VPS_IP`:

```bash
cat > config.json << 'EOF'
{
  "hostName": "YOUR_VPS_IP",
  "clearPlayerDreamInfoOnWake": true,
  "allowOverwritingPlayerDreamInfo": false,
  "allowPlayerGameVersionMismatch": false,
  "allowWfcRegistrationThroughLogin": true
}
EOF
```

### 7. Create .dockerignore

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

### 8. Create data directory

```bash
mkdir -p data
```

### 9. Build and Start

```bash
docker compose build
docker compose up -d
sleep 5
docker compose logs --tail 50
```

Look for: `Configure your DS to use the following DNS server: YOUR_VPS_IP`

---

## Verify It's Working

### Check all ports listening

```bash
sudo ss -tlnup | grep java
```

Should show:
- Port 80 (HTTP)
- Port 443 (HTTPS)
- Port 29900 (GameSpy)
- Port 53 (DNS)

### Test HTTP

```bash
curl http://localhost/
```

Should return: `Test`

### Test from another machine

```bash
curl http://YOUR_VPS_IP/
dig @YOUR_VPS_IP
```

---

## Common Commands

```bash
# View live logs
docker compose logs -f

# View last 100 lines
docker compose logs --tail 100

# Restart
docker compose restart

# Stop
docker compose stop

# Start
docker compose start

# Check status
docker compose ps

# View container details
docker inspect entralinked
```

---

## Firewall Configuration (If Needed)

If your VPS has UFW firewall:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 29900/tcp
sudo ufw allow 53/udp
sudo ufw status
```

---

## Configure Nintendo DS

1. Power on DS
2. Go to Settings → Wifi Settings
3. Select your connection
4. Edit settings
5. Set DNS Server: `YOUR_VPS_IP`
6. Save and test connection
7. Open Pokémon game
8. Access WiFi features (Dream World, GTS, Mystery Gift)

---

## Troubleshooting

**Container won't start:**
```bash
docker compose logs
docker compose build --no-cache
docker compose down -v
docker compose up -d
```

**Ports already in use:**
```bash
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :29900
sudo lsof -i :53
```

**Can't connect from DS:**
- Verify DNS is set correctly on DS
- Check firewall allows the ports
- Verify config.json has correct hostName
- Run: `docker compose restart`

**Check disk space:**
```bash
df -h
du -sh ~/entralinked-vps/data
```

---

## Support Files Included

- `Dockerfile` - Builds the container
- `docker-compose.yml` - Orchestrates the deployment
- `config.json` - Server configuration
- `.dockerignore` - Build optimization
- `DEPLOY.md` - Detailed deployment guide
- `quick-deploy.sh` - Automated deployment script

---

## Next Steps

1. Deploy to VPS using quick-deploy.sh
2. Verify all ports listening
3. Configure Nintendo DS DNS
4. Test WiFi connection from DS
5. Access Dream World / GTS features

That's it! Let me know if you need help!
