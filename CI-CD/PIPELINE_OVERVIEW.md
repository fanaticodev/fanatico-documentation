# Fanatico Sites CI/CD Pipeline Documentation

## Overview

The Fanatico Sites repository uses GitHub Actions for continuous integration and deployment (CI/CD) to automatically build and deploy changes to the Fremont2 production server.

## Repository Information

- **Repository**: https://github.com/fanaticodev/fanatico-sites
- **Type**: Monorepo containing 11+ Fanatico sites
- **Production Server**: Fremont2 (185.34.201.34)
- **Deployment Method**: SSH + Docker Compose

## Pipeline Architecture

```
Developer Push to Main Branch
            ↓
     GitHub Actions Triggered
            ↓
    SSH to Production Server
            ↓
     Pull Latest Code (Git)
            ↓
    Detect Changed Sites
            ↓
    Build Changed Sites (if needed)
            ↓
    Build Docker Images
            ↓
    Restart Containers
            ↓
    Cleanup & Health Checks
```

## Workflow Configuration

### File Location
`.github/workflows/deploy-production.yml`

### Trigger Conditions
```yaml
on:
  push:
    branches: [ main ]
    paths:
      - 'sites/**'
      - 'infrastructure/**'
  workflow_dispatch:  # Manual trigger
```

### Workflow Steps

1. **Checkout Code**
   - Uses: `actions/checkout@v4`
   - Purpose: Clone repository to runner

2. **Setup SSH**
   - Uses: `webfactory/ssh-agent@v0.9.0`
   - Loads private key from `FREMONT2_SSH_KEY` secret

3. **Add Server to Known Hosts**
   - Adds Fremont2 server fingerprint
   - Prevents SSH host verification prompts

4. **Pull Latest Code**
   ```bash
   ssh sites@185.34.201.34 "cd /home/sebastian/git-repos/fanatico-sites && git pull origin main"
   ```

5. **Detect Changed Sites**
   - Uses `git diff --name-only HEAD~1 HEAD`
   - Determines which sites need rebuilding
   - Sets `skip_build` flag if no changes

6. **Build Sites** (Conditional)
   - For each changed site with `package.json`:
     - Run `npm ci` (install dependencies)
     - Run `npm run build` (build production)
     - Sync `dist/` to production directory

7. **Rebuild Docker Images**
   ```bash
   cd /home/sebastian/sites && docker-compose -f docker-compose-dynamic-complete.yml build
   ```

8. **Restart Containers**
   ```bash
   cd /home/sebastian/sites && docker-compose -f docker-compose-dynamic-complete.yml up -d
   ```

9. **Cleanup**
   ```bash
   docker system prune -f
   ```

10. **Health Checks**
    - Waits 30 seconds for stabilization
    - Checks HTTP status of key sites
    - Reports health status

## Security Implementation

### GitHub Secrets
```
FREMONT2_HOST=185.34.201.34
FREMONT2_USER=sites
FREMONT2_SSH_KEY=<ED25519 private key>
```

### SSH Security Model

#### 1. Restricted User Account
- Username: `sites`
- Limited permissions
- Member of: sites, www-data, docker groups

#### 2. SSH Key Restrictions
```
command="/home/sites/github-deploy.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty
```

#### 3. Command Whitelist Script
Location: `/home/sites/github-deploy.sh`

**Allowed Operations**:
- Git operations (pull, status, diff)
- NPM operations (ci, build)
- Docker operations (build, up, restart, prune)
- File checks (package.json, dist)
- Rsync operations (deployment sync)
- Health checks (curl)

**Security Features**:
- Logs all attempts to syslog
- Rejects unauthorized commands
- No interactive shell access
- IP and command tracking

### Sample Whitelist Entry
```bash
case "$SSH_ORIGINAL_COMMAND" in
    "cd /home/sebastian/git-repos/fanatico-sites && git pull origin main")
        cd /home/sebastian/git-repos/fanatico-sites && git pull origin main
        ;;
    *)
        echo "ERROR: Command not allowed: $SSH_ORIGINAL_COMMAND"
        logger -t github-sites "REJECTED: Unauthorized command from ${SSH_CLIENT}"
        exit 1
        ;;
esac
```

## Directory Structure

### On Fremont2 Server
```
/home/sebastian/
├── git-repos/
│   └── fanatico-sites/        # Git repository (source)
│       ├── sites/
│       │   ├── fanatico.pro/
│       │   ├── fanatico.bet/
│       │   └── [other sites]/
│       └── .github/workflows/
└── sites/                      # Production deployment
    ├── docker-compose-dynamic-complete.yml
    ├── fanatico.pro/
    │   └── dist/              # Built files
    └── [other sites]/
```

### Deployment Flow
1. Code pushed to GitHub
2. GitHub Actions pulls to `/home/sebastian/git-repos/fanatico-sites/`
3. Sites built in git-repos directory
4. Built files synced to `/home/sebastian/sites/[site]/dist/`
5. Docker containers rebuilt from production directory

## Sites Included

| Site | URL | Type |
|------|-----|------|
| fanatico.pro | https://fanatico.pro | React + TypeScript |
| fanatico.bet | https://fanatico.bet | Betting platform |
| fanatico.me | https://fanatico.me | SSO with passkey auth |
| fanatico.cash | https://fanatico.cash | Gaming frontend |
| fanatico.vip | https://fanatico.vip | Static site |
| fanatico.xyz | https://fanatico.xyz | Static site |
| fanatico.social | https://fanatico.social | Static site |
| fanatico.chat | https://fanatico.chat | Static site |
| fanatico.club | https://fanatico.club | Static site |
| fanatico.games | https://fanatico.games | Static site |
| fanatico.app | https://fanatico.app | Static site |

## Docker Configuration

### Compose File
`docker-compose-dynamic-complete.yml`

### Network Configuration
- **web-network**: External access via NGINX
- **sites-internal**: Inter-container communication

### Container Naming
- Pattern: `sites_[domain]_app_1`
- Example: `sites_fanatico_pro_app_1`

## Monitoring

### GitHub Actions Dashboard
https://github.com/fanaticodev/fanatico-sites/actions

### Server Logs
```bash
# View deployment logs
sudo grep github-sites /var/log/syslog | tail -20

# Monitor in real-time
sudo tail -f /var/log/syslog | grep github-sites

# Check container status
docker ps --format "table {{.Names}}\t{{.Status}}"

# View container logs
docker logs sites_fanatico_pro_app_1 --tail 50
```

### Grafana Monitoring
https://grafana.fanati.co

## Troubleshooting

### Common Issues

#### 1. Workflow Fails with Exit Code 255
**Cause**: SSH connection failure
**Solution**: Verify secrets are correct, especially `FREMONT2_USER=sites`

#### 2. Command Rejected
**Cause**: Command not in whitelist
**Solution**: Add command pattern to `/home/sites/github-deploy.sh`

#### 3. Build Fails
**Cause**: Missing dependencies or build errors
**Solution**: Check package.json and build logs

#### 4. Container Won't Start
**Cause**: Port conflict or configuration error
**Solution**: Check docker-compose logs and port availability

### Debug Commands
```bash
# Test SSH connection
ssh -i /path/to/key sites@185.34.201.34 "echo test"

# Check whitelist script
sudo bash -n /home/sites/github-deploy.sh  # Syntax check

# View rejected commands
sudo grep "REJECTED" /var/log/syslog | tail -10

# Check Docker build logs
docker-compose -f docker-compose-dynamic-complete.yml logs [service]
```

## Rollback Procedure

### Quick Rollback
```bash
# SSH to server
ssh sites@185.34.201.34

# Revert git repository
cd /home/sebastian/git-repos/fanatico-sites
git log --oneline -5  # Find good commit
git reset --hard [commit-hash]

# Rebuild and restart
cd /home/sebastian/sites
docker-compose -f docker-compose-dynamic-complete.yml build
docker-compose -f docker-compose-dynamic-complete.yml up -d
```

### Manual Deployment
```bash
# If GitHub Actions is broken, deploy manually
ssh sebastian@185.34.201.34  # Use developer key

cd /home/sebastian/git-repos/fanatico-sites
git pull origin main

# Follow same build steps as workflow
cd sites/[site-name]
npm ci && npm run build
rsync -av dist/ /home/sebastian/sites/[site-name]/dist/

cd /home/sebastian/sites
docker-compose -f docker-compose-dynamic-complete.yml up -d
```

## Performance Metrics

- **Average Deployment Time**: 2-3 minutes
- **Git Pull**: ~3 seconds
- **NPM Build**: 10-30 seconds (per site)
- **Docker Build**: 15-30 seconds
- **Container Restart**: 2-5 seconds
- **Cleanup**: 60-90 seconds

## Best Practices

1. **Commit Messages**: Use conventional commits (feat:, fix:, docs:)
2. **Testing**: Test builds locally before pushing
3. **Monitoring**: Check GitHub Actions page after push
4. **Rollback**: Keep last known good commit documented
5. **Secrets**: Never commit secrets or keys to repository

## Maintenance

### Regular Tasks
- Review deployment logs weekly
- Clean up old Docker images monthly
- Update dependencies quarterly
- Rotate SSH keys annually

### Adding New Sites
1. Create site directory in `sites/`
2. Add to `docker-compose-dynamic-complete.yml`
3. Update NGINX configuration
4. Add health check to workflow
5. Test deployment pipeline

### Updating Workflow
1. Edit `.github/workflows/deploy-production.yml`
2. Test changes in feature branch
3. Create pull request
4. Merge to main after review

## Security Checklist

- [x] SSH key-only authentication
- [x] Restricted user account (sites)
- [x] Command whitelist active
- [x] All attempts logged
- [x] No interactive shell access
- [x] fail2ban protection
- [x] Secrets properly configured
- [x] Keys backed up securely
- [x] Regular security updates

## Contact & Support

**Repository**: https://github.com/fanaticodev/fanatico-sites
**Issues**: https://github.com/fanaticodev/fanatico-sites/issues
**Actions**: https://github.com/fanaticodev/fanatico-sites/actions
**Server**: Fremont2 (185.34.201.34)

---

**Last Updated**: November 12, 2025
**Pipeline Status**: ✅ FULLY OPERATIONAL
**Security Status**: ✅ HARDENED
**Monitoring**: ✅ ACTIVE