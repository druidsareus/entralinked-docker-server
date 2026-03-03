# Entralinked Docker Server

A complete Docker setup for running Entralinked (Pokémon WiFi emulation) on Debian 13 / Ubuntu 24.04+ VPS with full Nintendo DS compatibility.

## Features

✅ **Java 17 JRE** with TLS 1.0 support (required for Nintendo DS)  
✅ **Entralinked v1.4.1** pre-configured  
✅ **All 4 required ports**: 80 (HTTP), 443 (HTTPS), 29900 (GameSpy), 53 (DNS)  
✅ **One-command deployment** on Debian 13 VPS  
✅ **Persistent data storage** across restarts  
✅ **Auto-restart** on failure  

## Quick Start

### One-Line Deployment (5 minutes)

```bash
bash <(curl -s https://raw.githubusercontent.com/druidsareus/entralinked-docker-server/main/quick-deploy.sh) YOUR_VPS_IP
```

Replace `YOUR_VPS_IP` with your actual VPS IP (e.g., `187.124.81.115`).

That's it! The server will be running in the background.

### Manual Deployment

See [HOW_TO_DEPLOY.md](HOW_TO_DEPLOY.md) for step-by-step instructions.

## After Deployment

### Configure Nintendo DS

1. Go to DS Settings → WiFi Settings
2. Edit your connection
3. Set DNS Server: `YOUR_VPS_IP`
4. Test connection
5. Open Pokémon game and access WiFi features

### Verify Server

```bash
# SSH into your VPS
ssh root@YOUR_VPS_IP
cd ~/entralinked-vps

# Check status
docker compose ps

# View logs
docker compose logs -f

# Test HTTP endpoint
curl http://localhost/
```

## Common Commands

```bash
cd ~/entralinked-vps

# View live logs
docker compose logs -f

# View last 100 lines
docker compose logs --tail 100

# Restart server
docker compose restart

# Stop server
docker compose stop

# Start server
docker compose start

# Check status
docker compose ps
```

## File Structure

```
.
├── Dockerfile                 # Docker image (Java 17 + Entralinked)
├── docker-compose.yml        # Container configuration
├── config.json               # Server settings
├── .dockerignore             # Build optimization
├── quick-deploy.sh           # One-command deployment (easiest)
├── install-docker.sh         # Standalone Docker installer
├── HOW_TO_DEPLOY.md         # Quick deployment guide
├── COPY_PASTE_COMMANDS.md   # Ready-to-paste commands
├── VPS_DEPLOYMENT.md        # Detailed VPS guide
├── DEPLOY.md                # Full deployment guide
├── FILE_CHECKLIST.txt       # Pre-deployment checklist
└── README.md                # This file
```

## Documentation

- **[HOW_TO_DEPLOY.md](HOW_TO_DEPLOY.md)** - Start here! Three deployment methods
- **[COPY_PASTE_COMMANDS.md](COPY_PASTE_COMMANDS.md)** - Ready-to-paste terminal commands
- **[VPS_DEPLOYMENT.md](VPS_DEPLOYMENT.md)** - Detailed Debian 13 VPS instructions
- **[DEPLOY.md](DEPLOY.md)** - Complete deployment guide with troubleshooting
- **[FILE_CHECKLIST.txt](FILE_CHECKLIST.txt)** - Pre-deployment verification

## System Requirements

- **OS**: Debian 13 or Ubuntu 24.04+
- **CPU**: 1+ core
- **RAM**: 512MB minimum (1GB recommended)
- **Disk**: 2GB for Docker image, additional space for data
- **Ports**: 80, 443, 29900, 53 (all must be available)

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 80 | TCP | HTTP Dashboard |
| 443 | TCP | HTTPS Dashboard (self-signed cert) |
| 29900 | TCP | GameSpy Server (DS WiFi connection) |
| 53 | UDP | DNS Server |

## Java Configuration

- **Version**: 17 JRE
- **TLS**: TLSv1.0, TLSv1.1, TLSv1.2, TLSv1.3
- **Disabled Algorithms**: None (full DS compatibility)
- **Heap**: 512MB

## Troubleshooting

### Container won't start

```bash
docker compose logs
docker compose build --no-cache
docker compose down -v
docker compose up -d
```

### Ports already in use

```bash
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :29900
sudo lsof -i :53
```

### Can't connect from Nintendo DS

1. Verify DNS is set correctly on DS
2. Check firewall allows all 4 ports
3. Verify `config.json` has correct `hostName`
4. Restart: `docker compose restart`

### Out of disk space

```bash
docker system df
docker system prune -a
```

See [DEPLOY.md](DEPLOY.md#troubleshooting) for more solutions.

## Deployment Options

### Option 1: Automated (Easiest)

```bash
bash <(curl -s https://raw.../quick-deploy.sh) YOUR_VPS_IP
```

Takes 5 minutes. Fully automated.

### Option 2: Copy & Paste

See [COPY_PASTE_COMMANDS.md](COPY_PASTE_COMMANDS.md)

Takes 10 minutes. Full control.

### Option 3: Step-by-Step

See [HOW_TO_DEPLOY.md](HOW_TO_DEPLOY.md)

Takes 15 minutes. Fully explained.

## Configuration

Edit `config.json`:

```json
{
  "hostName": "YOUR_VPS_IP",
  "clearPlayerDreamInfoOnWake": true,
  "allowOverwritingPlayerDreamInfo": false,
  "allowPlayerGameVersionMismatch": false,
  "allowWfcRegistrationThroughLogin": true
}
```

Then restart: `docker compose restart`

## Maintenance

### Backup Data

```bash
tar -czf entralinked-backup-$(date +%Y%m%d).tar.gz data/
```

### Update to Latest Version

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### View Server Logs

```bash
# Real-time logs
docker compose logs -f

# Last 100 lines
docker compose logs --tail 100

# Specific service
docker compose logs entralinked
```

## Production Recommendations

1. **Use valid SSL certificate** instead of self-signed
   - Install Certbot: `sudo apt-get install certbot`
   - Use Let's Encrypt for free certificates

2. **Monitor container**
   - Set up log rotation
   - Monitor disk usage

3. **Backup regularly**
   ```bash
   tar -czf entralinked-backup-$(date +%Y%m%d).tar.gz data/
   ```

4. **Keep Docker updated**
   ```bash
   sudo apt-get update && sudo apt-get upgrade docker.io
   ```

## Related Links

- **Entralinked Repository**: https://github.com/kuroppoi/entralinked
- **Docker Documentation**: https://docs.docker.com/
- **Nintendo DS WiFi Services**: https://en.wikipedia.org/wiki/Nintendo_WiFi_Connection

## License

This Docker setup is provided as-is for educational and personal use. Entralinked is maintained by the Kuroppoi team. Please refer to the original Entralinked repository for licensing information.

## Support

For issues with deployment or Docker setup, see:
- [DEPLOY.md](DEPLOY.md) - Full troubleshooting guide
- [HOW_TO_DEPLOY.md](HOW_TO_DEPLOY.md) - Deployment help

For Entralinked-specific issues:
- [Entralinked GitHub Issues](https://github.com/kuroppoi/entralinked/issues)

## Contributing

If you find bugs or have improvements, feel free to open an issue or pull request.

---

**Ready to deploy?** Start with [HOW_TO_DEPLOY.md](HOW_TO_DEPLOY.md) or use the one-liner above!
