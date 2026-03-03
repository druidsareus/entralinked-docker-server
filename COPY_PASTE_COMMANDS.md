# Copy & Paste Deployment Commands

## OPTION 1: One-Line Automated Deployment (EASIEST)

SSH into your VPS and run this single command:

```bash
ssh root@YOUR_VPS_IP
```

Then run:

```bash
bash <(curl -s https://raw.githubusercontent.com/kuroppoi/entralinked/main/quick-deploy.sh) YOUR_VPS_IP
```

**Example with actual IP:**

```bash
bash <(curl -s https://raw.githubusercontent.com/kuroppoi/entralinked/main/quick-deploy.sh) 187.124.81.115
```

Wait 5 minutes and you're done.

---

## OPTION 2: Manual Step-by-Step (If Option 1 doesn't work)

### Step 1: SSH and Setup

```bash
ssh root@YOUR_VPS_IP
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker && sudo systemctl enable docker
mkdir -p ~/entralinked-vps && cd ~/entralinked-vps
```

### Step 2: Create All Files at Once

Copy and paste this entire block:

```bash
cat > Dockerfile << 'DOCKEREOF'
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
DOCKEREOF

cat > docker-compose.yml << 'COMPOSEEOF'
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
COMPOSEEOF

cat > config.json << 'CONFIGEOF'
{
  "hostName": "187.124.81.115",
  "clearPlayerDreamInfoOnWake": true,
  "allowOverwritingPlayerDreamInfo": false,
  "allowPlayerGameVersionMismatch": false,
  "allowWfcRegistrationThroughLogin": true
}
CONFIGEOF

cat > .dockerignore << 'IGNOREEOF'
data
config.json
.git
.gradle
build
*.log
IGNOREEOF

mkdir -p data
```

**IMPORTANT:** Replace `187.124.81.115` in the config.json section with your actual VPS IP!

### Step 3: Build and Start

```bash
docker compose build
docker compose up -d
sleep 5
docker compose logs --tail 50
```

---

## Verify Deployment

After either option, run these commands:

```bash
# Check if container is running
docker compose ps

# Check listening ports
sudo ss -tlnup | grep java

# Test HTTP
curl http://localhost/

# View logs
docker compose logs --tail 100
```

---

## Configure Your DS

Set Nintendo DS DNS to: **187.124.81.115** (or your actual VPS IP)

---

## If Something Goes Wrong

```bash
# View full logs
docker compose logs

# Restart
docker compose restart

# Rebuild from scratch
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

---

## Key Files Reference

Your deployment directory will have:

```
~/entralinked-vps/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Orchestration config
├── config.json             # Server config (EDIT VPS IP HERE)
├── .dockerignore           # Build optimization
└── data/                   # Persistent data
    ├── players/            # Player data
    ├── dlc/                # DLC files
    └── logs/               # Server logs
```

---

## Need Help?

Check the detailed guides:
- `DEPLOY.md` - Full deployment guide
- `VPS_DEPLOYMENT.md` - VPS-specific instructions
- GitHub: https://github.com/kuroppoi/entralinked

---

## Quick Reference: Common Commands

```bash
cd ~/entralinked-vps

# Logs
docker compose logs -f                    # Live logs
docker compose logs --tail 200            # Last 200 lines

# Control
docker compose restart                    # Restart
docker compose stop                       # Stop
docker compose start                      # Start
docker compose down                       # Stop & remove

# Info
docker compose ps                         # Status
docker inspect entralinked                # Details

# Cleanup
docker system prune -a                    # Clean unused
docker system df                          # Disk usage
```

---

Done! Your Entralinked server is ready to emulate Nintendo DS WiFi!
