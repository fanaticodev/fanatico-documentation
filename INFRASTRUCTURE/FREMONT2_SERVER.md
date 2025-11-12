# Fremont2 Production Server Documentation

## Server Overview

Fremont2 is the primary production server hosting all Fanatico network services.

## Hardware Specifications

- **Model**: Dell PowerEdge R730
- **CPU**: 2x Intel Xeon E5-2620 v4 @ 2.10GHz (16 cores, 32 threads total)
- **RAM**: 32GB DDR4 ECC
- **Storage**:
  - System: 160GB SSD (/)
  - Docker: 1TB NVMe SSD (/mnt/nvm)
- **Network**: 4x 1Gbps Ethernet (bonded)
- **IPMI**: iDRAC8 Enterprise

## Operating System

- **OS**: Ubuntu 24.04 LTS (Noble Numbat)
- **Kernel**: 6.8.0-87-generic
- **Docker**: 24.0.7
- **Docker Compose**: 2.21.0

## Network Configuration

### Public IP Addresses
- Primary Range: 185.34.201.34-37
- Additional IPs: 185.34.201.64, .185, .201-.203

### Internal Docker Networks
| Network | CIDR | Purpose |
|---------|------|---------|
| web-network | 172.28.0.0/16 | Web applications |
| ping-network | 172.27.0.0/16 | Monitoring stack |
| trace-network | 172.23.0.0/16 | Blockchain services |
| trade-internal | 172.24.0.0/16 | Trading platform |
| mailcow-network | 172.30.3.0/24 | Email services |
| grafana-network | 172.29.0.0/16 | Monitoring dashboards |

## Directory Structure

```
/home/sebastian/
├── git-repos/               # Git repositories
│   ├── fanatico-sites/     # Sites monorepo
│   └── fanatico-cash/      # Aviator game
├── sites/                   # Production deployments
│   ├── docker-compose-dynamic-complete.yml
│   ├── fanatico.pro/
│   ├── fanatico.bet/
│   └── [other sites]/
├── ping/                    # Monitoring system
├── trace/                   # Blockchain analysis
├── trade/                   # Trading platform
├── nginx/                   # Reverse proxy
├── grafana/                 # Monitoring dashboards
├── mailserver/              # Email stack
├── documentation/           # System documentation
└── scripts/                 # Automation scripts

/mnt/nvm/
└── docker/                  # Docker volumes
    └── volumes/            # Persistent data
```

## Service Inventory

### Total Containers: 74+

| Service Category | Container Count | Primary Purpose |
|-----------------|----------------|-----------------|
| SITES | 18 | Web hosting |
| PING | 7 | API monitoring |
| TRACE | 7 | Blockchain tracking |
| TRADE | 6 | Trading platform |
| MAILCOW | 18 | Email services |
| GRAFANA | 5 | Monitoring |
| NGINX | 1 | Reverse proxy |
| SYSTEM | 4 | System monitoring |
| Other | 8 | Supporting services |

## Access Management

### SSH Users

| User | Purpose | Access Level |
|------|---------|-------------|
| sebastian | Primary admin | Full sudo access |
| sites | CI/CD deployment | Restricted commands |
| root | System admin | Direct login disabled |

### SSH Security
- Key-based authentication only
- Password authentication disabled
- fail2ban protection active
- Port 22 (standard SSH port)

## Docker Configuration

### Docker Daemon
- Storage Driver: overlay2
- Root Directory: /mnt/nvm/docker
- Logging Driver: json-file
- Default Network: bridge

### Resource Limits
- Memory: No global limit (32GB available)
- CPU: No global limit (32 threads available)
- Disk: 916GB available on /mnt/nvm

## System Monitoring

### Metrics Collection
- Prometheus (4 instances)
- Grafana dashboards
- cAdvisor for containers
- Node Exporter for system

### Key Metrics
- CPU Usage: ~20-30% average
- Memory: 17-20GB used
- Disk I/O: Moderate
- Network: 10-50 Mbps average

## Backup Configuration

### Automated Backups
- Method: Pull-based from Jetson backup server
- Schedule: Daily at 2 AM UTC (rsync)
- Additional: Kopia snapshots at 3 AM UTC
- Destination: B2 cloud storage
- Retention: 30 days

### Manual Backup Paths
```bash
# Databases
/mnt/nvm/docker/volumes/

# Configurations
/home/sebastian/*/docker-compose*.yml
/home/sebastian/*/.env

# SSL Certificates
/home/sebastian/certbot/
/etc/letsencrypt/
```

## Maintenance Procedures

### System Updates
```bash
# Check for updates
sudo apt update
sudo apt list --upgradable

# Apply security updates only
sudo apt install --only-upgrade $(apt list --upgradable 2>/dev/null | grep -i security | cut -d'/' -f1)

# Full system upgrade (careful)
sudo apt upgrade
```

### Docker Cleanup
```bash
# Remove unused containers, images, volumes
docker system prune -af --volumes

# Check disk usage
docker system df

# Clean build cache
docker builder prune
```

### Service Restart
```bash
# Individual service
cd /home/sebastian/[service]
docker-compose restart [container]

# All services (CAUTION)
cd /home/sebastian/sites
docker-compose -f docker-compose-dynamic-complete.yml restart
```

## Security Hardening

### Firewall Status
- UFW: Currently INACTIVE
- Protection via:
  - Docker network isolation
  - Database localhost binding
  - Network-level firewall (router)
  - fail2ban for SSH

### Open Ports
| Port | Service | Access |
|------|---------|--------|
| 22 | SSH | Public |
| 80 | HTTP | Public |
| 443 | HTTPS | Public |
| 25,143,587,993 | Email | Public |

### Security Measures
- Regular security updates
- SSH key rotation
- Docker image updates
- SSL certificate renewal
- Audit log monitoring

## Performance Optimization

### System Tuning
- Swappiness: 10
- File descriptors: 65536
- Max user processes: 32768

### Docker Optimization
- Log rotation configured
- Unused resources pruned daily
- Memory limits on critical containers
- Health checks on all services

## Disaster Recovery

### Recovery Time Objectives
- RTO: 4 hours
- RPO: 24 hours

### Recovery Procedures
1. Provision new server
2. Restore from backup
3. Update DNS records
4. Verify services
5. Monitor stability

## Contact Information

- **Location**: Data Center
- **Remote Access**: SSH, IPMI
- **Monitoring**: https://grafana.fanati.co
- **Status Page**: Internal only

## Related Documentation

- [Docker Architecture](DOCKER_ARCHITECTURE.md)
- [Network Topology](NETWORK_TOPOLOGY.md)
- [Backup Procedures](../OPERATIONS/BACKUP_RECOVERY.md)
- [Security Configuration](../SECURITY/SSH_SECURITY.md)