# Fanatico Infrastructure Documentation

## Overview

Comprehensive documentation for the Fanatico network infrastructure, including CI/CD pipelines, deployment procedures, server configuration, and security implementations.

## Repository Structure

```
.
├── README.md                           # This file
├── CI-CD/                             # CI/CD Pipeline documentation
│   ├── PIPELINE_OVERVIEW.md          # Complete pipeline documentation
│   ├── GITHUB_ACTIONS_SETUP.md       # GitHub Actions configuration
│   └── DEPLOYMENT_WORKFLOW.md        # Deployment process details
├── AI-CODING/                        # AI Coding Agents documentation
│   ├── README.md                     # AI tools overview and quick start
│   ├── AI-CODING-AGENTS-IMPLEMENTATION-ROADMAP.md  # Complete implementation plan
│   ├── Claude-AI-Coding-Agents.md   # Claude-based tools analysis
│   ├── Gemini-AI-Coding-Agents.md   # Gemini integration research
│   └── [10+ more documents]          # Comprehensive AI research
├── INFRASTRUCTURE/                    # Server and infrastructure docs
│   ├── FREMONT2_SERVER.md           # Fremont2 server documentation
│   ├── DOCKER_ARCHITECTURE.md       # Docker configuration
│   └── NETWORK_TOPOLOGY.md          # Network setup and IPs
├── SECURITY/                         # Security implementations
│   ├── SSH_SECURITY.md              # SSH configuration and keys
│   ├── GITHUB_ACTIONS_SECURITY.md   # CI/CD security model
│   └── COMMAND_WHITELIST.md         # Command restriction details
├── SITES/                            # Individual site documentation
│   ├── SITES_OVERVIEW.md            # All sites summary
│   ├── FANATICO_PRO.md             # fanatico.pro specifics
│   └── DEPLOYMENT_PATHS.md          # Directory structures
├── TROUBLESHOOTING/                  # Common issues and solutions
│   ├── COMMON_ISSUES.md             # Frequent problems
│   ├── DEBUG_COMMANDS.md            # Useful debugging commands
│   └── ROLLBACK_PROCEDURES.md       # Recovery procedures
└── OPERATIONS/                       # Operational procedures
    ├── MONITORING.md                 # Monitoring setup
    ├── BACKUP_RECOVERY.md           # Backup procedures
    └── MAINTENANCE.md                # Regular maintenance tasks
```

## Quick Links

### Essential Documentation

- [AI Coding Agents Roadmap](AI-CODING/README.md) - AI tools implementation guide
- [CI/CD Pipeline Overview](CI-CD/PIPELINE_OVERVIEW.md) - Complete GitHub Actions pipeline
- [Fremont2 Server Guide](INFRASTRUCTURE/FREMONT2_SERVER.md) - Production server details
- [Security Implementation](SECURITY/SSH_SECURITY.md) - SSH and security configuration
- [Troubleshooting Guide](TROUBLESHOOTING/COMMON_ISSUES.md) - Common problems and fixes

### Key Resources

- **GitHub Organization**: https://github.com/fanaticodev
- **Fanatico Sites Repository**: https://github.com/fanaticodev/fanatico-sites
- **Production Server**: Fremont2 (185.34.201.34)
- **Monitoring Dashboard**: https://grafana.fanati.co

## Infrastructure Summary

### Fremont2 Server
- **Hardware**: Dell PowerEdge R730
- **OS**: Ubuntu 24.04 LTS
- **CPU**: 2x Xeon E5-2620 v4 (32 cores)
- **RAM**: 32GB
- **Storage**: 1TB NVMe SSD
- **Network**: 185.34.201.34-37 (primary IPs)
- **Containers**: 74+ Docker containers

### Deployed Sites (All Operational)
- fanatico.pro - Ready for new codebase (Aviator archived)
- fanatico.bet - Betting Platform (Node.js + MariaDB)
- fanatico.me - SSO with Passkey Auth (Node.js + Redis)
- fanatico.cash - Aviator Crash Game (React + Socket.IO + MongoDB)
- fanatico.vip - VIP Portal (migrated November 2025)
- fanatico.xyz, .social, .chat, .club, .games, .app - Static Sites
- partners.fanati.co - Partner Portal (PHP 8.1 + NGINX)

### CI/CD Pipeline
- **Platform**: GitHub Actions
- **Trigger**: Push to main branch
- **Deployment**: SSH + Docker Compose
- **Security**: Restricted SSH with command whitelist
- **Duration**: 2-3 minutes average

## Security Model

### Three-Layer Security
1. **Network Layer**: fail2ban, port restrictions
2. **Authentication Layer**: SSH key-only access
3. **Authorization Layer**: Command whitelist for CI/CD

### Access Control
- **Developer Access**: Full SSH via sebastian user
- **CI/CD Access**: Restricted SSH via sites user
- **Command Whitelist**: `/home/sites/github-deploy.sh`
- **Audit Logging**: All attempts logged to syslog

## Quick Start

### For Developers

1. Clone the fanatico-sites repository
2. Make changes and push to main branch
3. GitHub Actions automatically deploys
4. Monitor deployment at GitHub Actions page

### For Operations

1. SSH to Fremont2: `ssh sebastian@185.34.201.34`
2. Check container status: `docker ps`
3. View deployment logs: `sudo grep github-sites /var/log/syslog`
4. Monitor metrics at https://grafana.fanati.co

## Support

### Documentation Issues
Report issues or suggest improvements by creating an issue in this repository.

### Infrastructure Support
- **Server Access**: Contact system administrator
- **Deployment Issues**: Check GitHub Actions logs first
- **Security Concerns**: Review security documentation

## Contributing

To contribute to this documentation:
1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

Internal documentation - Proprietary and Confidential

---

**Last Updated**: November 25, 2025
**Maintained By**: Fanatico Development Team
**Status**: Active and Current