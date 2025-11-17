# Netflyx

A self-hosted media automation and streaming platform that combines the power of multiple services into a unified, privacy-focused stack. Built with Docker Compose for easy deployment and management.

## Overview

Netflyx integrates media request management, automated downloading, and streaming capabilities into a single cohesive system. All torrent traffic is routed through a VPN for privacy, while Cloudflare tunnel support enables secure remote access without exposing ports.

## Features

- **Automated Media Management**: Request, download, and organize TV shows and movies automatically
- **Streaming Server**: Stream your media library to any device with Jellyfin
- **User-Friendly Requests**: Let users request content through Jellyseerr's intuitive interface
- **VPN Protection**: All torrent traffic routes through ProtonVPN with WireGuard for privacy
- **Tracker Injection**: Automatic addition of public trackers to improve download speeds
- **Cloudflare Bypass**: FlareSolverr handles Cloudflare-protected indexers
- **Secure Remote Access**: Optional Cloudflare tunnel for accessing services from anywhere
- **Hardware Acceleration**: GPU transcoding support for Jellyfin

## Architecture

### Service Stack

```
┌─────────────┐
│ Jellyseerr  │ ← Users request content
└──────┬──────┘
       │
       v
┌─────────────────────┐
│ Sonarr  │  Radarr   │ ← Automation for TV/Movies
└─────────┬───────────┘
          │
          v
┌─────────────┐     ┌──────────────┐
│  Prowlarr   │────→│ FlareSolverr │ ← Indexer management + CF bypass
└──────┬──────┘     └──────────────┘
       │                    │
       └────────┬───────────┘
                │         (Both route through VPN)
                v
         ┌─────────────┐
         │   Gluetun   │ ← VPN container (ProtonVPN)
         │  (VPN/WG)   │
         └──────┬──────┘
                │
                v
         ┌─────────────┐
         │ qBittorrent │ ← Torrent client
         └──────┬──────┘
                │
                v
         ┌─────────────┐
         │  Downloads  │
         └──────┬──────┘
                │
                v
         ┌─────────────┐
         │   Jellyfin  │ ← Media server
         └─────────────┘
                │
                v
         ┌─────────────┐
         │    Users    │ ← Stream content
         └─────────────┘
```

### Network Flow

- **Media requests** flow from Jellyseerr → Sonarr/Radarr → Prowlarr → qBittorrent
- **Torrent traffic** is routed through the Gluetun VPN container
- **FlareSolverr and TinyProxy** share the VPN network using `network_mode: service:gluetun`
- **Cloudflared** provides secure external access without exposing ports directly

## Prerequisites

- Docker and Docker Compose installed
- Linux host (or compatible OS with Docker support)
- **ProtonVPN account** with WireGuard support (required for VPN)
- *Optional*: Cloudflare account (for remote access tunnel)
- At least 4GB RAM recommended
- Storage space for media library

## Quick Start

### 1. Clone and Configure

```bash
git clone <repository-url>
cd netflyx
cp .env.example .env
```

### 2. Configure Environment Variables

Edit the `.env` file with your settings:

**Required Variables:**

```bash
# User/Group IDs (get with: id -u and id -g)
PUID=1000
PGID=1000

# Timezone
TZ=America/Sao_Paulo

# TinyProxy Authentication
TINYPROXY_USER=admin
TINYPROXY_PASSWORD=changeme  # Change this!

# VPN Configuration (ProtonVPN)
WIREGUARD_PRIVATE_KEY="your_wireguard_private_key_here"
WIREGUARD_ADDRESSES=10.2.0.2/32
SERVER_COUNTRIES=Netherlands

# Optional: Cloudflare Tunnel
CLOUDFLARED_TOKEN="your_cloudflare_tunnel_token"
```

**Getting WireGuard Keys:**
1. Log into ProtonVPN dashboard
2. Go to Account → WireGuard configuration
3. Generate a key and copy the private key to your `.env` file

### 3. Prepare Directory Structure

The required directories will be created automatically, but you can verify:

```bash
mkdir -p data/{config,media,downloads}/{jellyfin,jellyseerr,sonarr,radarr,prowlarr,qbittorrent,tinyproxy}
mkdir -p data/media/{tv,movies}
mkdir -p data/downloads/{shows,movies}
```

### 4. Start Services

```bash
docker compose up -d
```

### 5. Access Services

Once running, access the web interfaces:

| Service | URL | Purpose |
|---------|-----|---------|
| Jellyfin | http://localhost:8096 | Media streaming |
| Jellyseerr | http://localhost:5055 | Request content |
| Sonarr | http://localhost:8989 | TV automation |
| Radarr | http://localhost:7878 | Movie automation |
| Prowlarr | http://localhost:9696 | Indexer management |
| qBittorrent | http://localhost:8080 | Torrent client |

## Service Configuration

### 1. Jellyfin (Media Server)

**First-time setup:**
1. Access http://localhost:8096
2. Follow the setup wizard
3. Add media libraries:
   - **TV Shows**: `/data/media/tv`
   - **Movies**: `/data/media/movies`
4. Enable hardware acceleration in Dashboard → Playback (if using GPU)

### 2. qBittorrent (Torrent Client)

**IMPORTANT - Change Default Credentials:**

Default login: `admin` / `adminadmin`

1. Access http://localhost:8080
2. Log in with default credentials
3. **Immediately change password**: Tools → Options → Web UI → Authentication
4. Configure categories:
   - `tv-sonarr` → `/data/downloads/shows`
   - `movies-radarr` → `/data/downloads/movies`

### 3. Prowlarr (Indexer Manager)

1. Access http://localhost:9696
2. Add indexers: Indexers → Add Indexer
3. Configure FlareSolverr for Cloudflare-protected indexers:
   - Settings → Indexers → FlareSolverr
   - URL: `http://gluetun:8191`
4. Add apps to sync indexers:
   - Settings → Apps → Add Application
   - **Sonarr**: http://sonarr:8989
   - **Radarr**: http://radarr:7878

### 4. Sonarr (TV Shows)

1. Access http://localhost:8989
2. Settings → Media Management:
   - Root Folder: `/data/media/tv`
3. Settings → Download Clients:
   - Add qBittorrent
   - Host: `qbittorrent`
   - Port: `8080`
   - Category: `tv-sonarr`
4. Wait for Prowlarr to sync indexers (or add manually)
5. *Optional*: Configure webhook for tracker injection (see below)

### 5. Radarr (Movies)

1. Access http://localhost:7878
2. Settings → Media Management:
   - Root Folder: `/data/media/movies`
3. Settings → Download Clients:
   - Add qBittorrent
   - Host: `qbittorrent`
   - Port: `8080`
   - Category: `movies-radarr`
4. Wait for Prowlarr to sync indexers
5. *Optional*: Configure webhook for tracker injection

### 6. Jellyseerr (Request Management)

1. Access http://localhost:5055
2. Sign in with your Jellyfin admin account
3. Connect to Jellyfin:
   - URL: `http://jellyfin:8096`
4. Connect to Sonarr and Radarr
5. Configure user permissions and request limits

## Tracker Automation

The `add-trackers.sh` script automatically injects public trackers into torrents to improve peer discovery and download speeds.

### What It Does

- Fetches live tracker lists from multiple sources
- Adds 100+ public trackers to torrents
- Respects private torrents (won't inject by default)
- Can be triggered automatically via webhooks or run manually

### Manual Usage

```bash
# List all torrents
docker compose exec sonarr /config/add-trackers.sh -l

# Add trackers to specific torrent by name
docker compose exec qbittorrent /config/add-trackers.sh -n "Ubuntu"

# Add trackers to all torrents
docker compose exec qbittorrent /config/add-trackers.sh -a

# Add trackers by category
docker compose exec qbittorrent /config/add-trackers.sh -s "tv-sonarr"

# Clean existing trackers and add fresh list
docker compose exec qbittorrent /config/add-trackers.sh -c -a
```

### Automatic Webhook Setup

**For Sonarr:**
1. Settings → Connect → Add → Webhook
2. Name: `Tracker Injection`
3. Triggers: ✓ On Download, ✓ On Import
4. URL: `http://sonarr:8989/api/v1/command`
5. Method: `POST`

**For Radarr:**
1. Settings → Connect → Add → Webhook
2. Name: `Tracker Injection`
3. Triggers: ✓ On Download, ✓ On Import
4. URL: `http://radarr:7878/api/v1/command`
5. Method: `POST`

## Port Reference

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 8096 | Jellyfin | HTTP | Web interface |
| 8920 | Jellyfin | HTTPS | Secure web interface |
| 7359 | Jellyfin | UDP | Network discovery |
| 1900 | Jellyfin | UDP | DLNA |
| 5055 | Jellyseerr | HTTP | Request interface |
| 8989 | Sonarr | HTTP | TV automation |
| 7878 | Radarr | HTTP | Movie automation |
| 9696 | Prowlarr | HTTP | Indexer management |
| 8080 | qBittorrent | HTTP | Torrent web UI |
| 6881 | qBittorrent | TCP/UDP | Torrent traffic (via VPN) |
| 8888 | TinyProxy | HTTP | Proxy (via VPN) |
| 8191 | FlareSolverr | HTTP | CF bypass (via VPN) |

## Security Best Practices

### Critical Security Steps

#### 1. Change Default Passwords

**qBittorrent** (Default: admin/adminadmin):
- Change immediately after first login
- Tools → Options → Web UI → Authentication

**Update Script Credentials:**
```bash
# Edit the add-trackers.sh scripts to update hardcoded credentials
vi data/config/sonarr/add-trackers.sh
vi data/config/radarr/add-trackers.sh
vi data/config/qbittorrent/add-trackers.sh

# Find and update this line:
QBITTORRENT_CREDENTIALS="fly:VSNwvqBIzT80Hf"
```

#### 2. Secure Your Environment File

```bash
# Never commit .env to version control
chmod 600 .env

# Verify .env is in .gitignore
grep "^\.env$" .gitignore
```

#### 3. TinyProxy Credentials

TinyProxy credentials are configured via environment variables in your `.env` file:
```bash
# Change these in your .env file:
TINYPROXY_USER=your_username
TINYPROXY_PASSWORD=your_secure_password
```

After changing credentials, rebuild and restart the container:
```bash
docker compose up -d --build tinyproxy
```

### VPN Kill-Switch

The VPN acts as a kill-switch for torrent traffic:
- qBittorrent only accessible through Gluetun container
- If VPN disconnects, torrent traffic stops
- FlareSolverr and TinyProxy also protected via `network_mode: service:gluetun`

### Network Isolation

- All services isolated in custom Docker network
- MTU set to 1420 for VPN compatibility
- Only specified ports exposed to host

### File Permissions

Use correct PUID/PGID to avoid permission issues:
```bash
# Get your user/group IDs
id -u  # PUID
id -g  # PGID

# Update in .env file
PUID=1000
PGID=1000
```

## Troubleshooting

### VPN Connection Issues

**Problem**: Gluetun fails to connect or restarts repeatedly

**Solutions**:
```bash
# Check Gluetun logs
docker compose logs -f gluetun

# Verify WireGuard key is correct in .env
grep WIREGUARD_PRIVATE_KEY .env

# Test with different server country
# Edit .env: SERVER_COUNTRIES=Switzerland
docker compose up -d gluetun

# Ensure firewall allows UDP 51820 (WireGuard)
sudo ufw allow 51820/udp
```

### Permission Errors

**Problem**: Services can't write to directories

**Solutions**:
```bash
# Verify PUID/PGID match your user
id

# Fix ownership of data directory
sudo chown -R 1000:1000 data/

# Restart services
docker compose restart
```

### Services Can't Communicate

**Problem**: Sonarr can't reach qBittorrent, Prowlarr can't sync, etc.

**Solutions**:
```bash
# Use service names, not localhost
# ✓ Correct: http://qbittorrent:8080
# ✗ Wrong: http://localhost:8080

# Verify all services on same network
docker compose ps

# Check service logs
docker compose logs <service-name>
```

### Tracker Injection Not Working

**Problem**: `add-trackers.sh` fails or doesn't add trackers

**Solutions**:
```bash
# Test script manually
docker compose exec qbittorrent /config/add-trackers.sh -l

# Check if jq and curl are available
docker compose exec qbittorrent which jq curl

# Verify qBittorrent credentials in script
docker compose exec qbittorrent cat /config/add-trackers.sh | grep QBITTORRENT_CREDENTIALS

# Check qBittorrent Web API is enabled
# Login to WebUI → Tools → Options → Web UI → Enable Web UI
```

### Port Forwarding Not Working

**Problem**: Slow download speeds or no connections

**Solutions**:
```bash
# Verify VPN port forwarding is enabled in .env
VPN_PORT_FORWARDING=on
PORT_FORWARD_ONLY=on

# Check forwarded port in Gluetun logs
docker compose logs gluetun | grep "port forward"

# Update qBittorrent listening port to match forwarded port
# Tools → Options → Connection → Listening Port
```

### Jellyfin Hardware Acceleration Issues

**Problem**: Transcoding not using GPU

**Solutions**:
```bash
# Verify GPU devices exist
ls -la /dev/dri

# Check user permissions
groups
# Should include 'video' or 'render'

# Add user to video group
sudo usermod -a -G video $USER
sudo usermod -a -G render $USER

# Restart Docker
sudo systemctl restart docker
docker compose restart jellyfin
```

## Project Structure

```
netflyx/
├── docker-compose.yml          # Service orchestration
├── .env                        # Environment configuration (gitignored)
├── .env.example                # Environment template
├── docker/
│   └── Dockerfile.tinyproxy    # Custom TinyProxy image
├── data/
│   ├── config/                 # Service configurations (gitignored)
│   │   ├── jellyfin/
│   │   ├── jellyseerr/
│   │   ├── sonarr/            # Contains add-trackers.sh
│   │   ├── radarr/            # Contains add-trackers.sh
│   │   ├── prowlarr/
│   │   ├── qbittorrent/       # Contains add-trackers.sh
│   │   └── tinyproxy/
│   ├── media/                 # Media library (gitignored)
│   │   ├── tv/
│   │   └── movies/
│   └── downloads/             # Torrent downloads (gitignored)
│       ├── shows/
│       └── movies/
├── CLAUDE.md                  # AI assistant guidance
└── README.md                  # This file
```

## Common Commands

### Docker Operations

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# Restart specific service
docker compose restart <service-name>

# View logs for all services
docker compose logs -f

# View logs for specific service
docker compose logs -f <service-name>

# Rebuild service after changes
docker compose up -d --build <service-name>

# Pull latest images
docker compose pull

# Check service status
docker compose ps

# Execute command in container
docker compose exec <service-name> <command>
```

### Maintenance

```bash
# Clean up unused Docker resources
docker system prune -a

# Backup configuration
tar -czf netflyx-config-backup.tar.gz data/config/

# Restore configuration
tar -xzf netflyx-config-backup.tar.gz

# Monitor resource usage
docker stats
```

### Tracker Management

```bash
# Add trackers to all torrents
docker compose exec qbittorrent /config/add-trackers.sh -a

# List all torrents with categories
docker compose exec qbittorrent /config/add-trackers.sh -l

# Add trackers to specific category
docker compose exec qbittorrent /config/add-trackers.sh -s "tv-sonarr"
```

## Contributing

This is a personal project, but suggestions and improvements are welcome! Feel free to:
- Open issues for bugs or feature requests
- Submit pull requests with improvements
- Share your configuration tips

## License

This project is provided as-is for personal use. Individual services (Jellyfin, Sonarr, etc.) maintain their own licenses.

---

**Questions or issues?** Check the [Troubleshooting](#troubleshooting) section or review service logs with `docker compose logs -f <service-name>`
