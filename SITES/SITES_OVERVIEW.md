# Fanatico Sites Overview

## Production Sites

The Fanatico network consists of 11+ sites hosted on Fremont2 server, all managed through a monorepo and deployed via Docker containers.

## Sites Directory

| Domain | Type | Technology | Container | Status |
|--------|------|------------|-----------|--------|
| **fanatico.pro** | Ready for New Code | Directory Prepared | sites_fanatico_pro_app_1 | 📦 Ready |
| **fanatico.bet** | Betting Platform | Node.js + MariaDB + Redis | sites_fanatico_bet_app_1 | ✅ Active |
| **fanatico.me** | SSO Portal | Node.js + Passkey Auth + Redis | sites_fanatico_me_app_1 | ✅ Active |
| **fanatico.cash** | Aviator Game | React + Socket.IO + Node.js + MongoDB | sites_aviator_frontend_1, sites_aviator_backend_1 | ✅ Active |
| **fanatico.vip** | VIP Portal | Static Site (Migrated Nov 2025) | sites_fanatico_vip_app_1 | ✅ Active |
| **fanatico.xyz** | Static Site | HTML/CSS/JS | sites_fanatico_xyz_app_1 | ✅ Active |
| **fanatico.social** | Social Platform | HTML/CSS/JS | sites_fanatico_social_app_1 | ✅ Active |
| **fanatico.chat** | Chat Interface | HTML/CSS/JS | sites_fanatico_chat_app_1 | ✅ Active |
| **fanatico.club** | Club Portal | HTML/CSS/JS | sites_fanatico_club_app_1 | ✅ Active |
| **fanatico.games** | Gaming Hub | HTML/CSS/JS | sites_fanatico_games_app_1 | ✅ Active |
| **fanatico.app** | Application Portal | HTML/CSS/JS | sites_fanatico_app_app_1 | ✅ Active |
| **partners.fanati.co** | Partner Portal | PHP 8.1 + NGINX (HybridMLM) | partners_app | ✅ Active |

## Architecture Overview

### Monorepo Structure
```
fanatico-sites/
├── sites/                    # Individual site directories
│   ├── fanatico.pro/        # Each site has its own directory
│   │   ├── src/            # Source code
│   │   ├── public/         # Static assets
│   │   ├── package.json    # Dependencies
│   │   ├── Dockerfile      # Container definition
│   │   └── dist/           # Build output
│   └── [other-sites]/
├── infrastructure/           # Shared infrastructure
│   └── docker-compose-production.yml
└── shared/                   # Shared components
    ├── components/
    └── utils/
```

### Deployment Architecture

1. **Source Control**: GitHub (fanaticodev/fanatico-sites)
2. **CI/CD**: GitHub Actions
3. **Build Process**:
   - React/TypeScript sites: Vite build
   - Static sites: Direct copy
   - Node.js apps: TypeScript compilation
4. **Containerization**: Docker with Alpine Linux
5. **Reverse Proxy**: NGINX
6. **SSL**: Let's Encrypt via Certbot

## Site-Specific Details

### fanatico.pro - Ready for New Implementation
- **Status**: Directory prepared for new codebase
- **Previous Code**: Aviator game archived to branch `archive/fanatico.pro-aviator-v1`
- **Container**: NGINX Alpine ready
- **Deployment**: CI/CD pipeline configured
- **Note**: Awaiting new codebase implementation

### fanatico.bet - Betting Platform
- **Backend**: Node.js + Express
- **Database**: MariaDB
- **Authentication**: JWT
- **Features**: Sports betting, live odds, user wallets
- **Container**: Node.js Alpine + MariaDB

### fanatico.me - SSO Portal
- **Technology**: Node.js + Express
- **Authentication**: WebAuthn (Passkeys)
- **Session**: Redis
- **Features**: Single sign-on, biometric auth
- **Container**: Node.js Alpine

### fanatico.cash - Aviator Crash Game
- **Repository**: Separate repo at [fanaticodev/fanatico-cash](https://github.com/fanaticodev/fanatico-cash)
- **Frontend**: React with SPA routing (Fixed Nov 25, 2025)
- **Backend**: Node.js + Express + Socket.IO
- **Database**: MongoDB
- **Features**: Real-time multiplayer crash game, FCO tokens
- **Containers**: sites_aviator_frontend_1 + sites_aviator_backend_1 + sites_aviator_mongo_1
- **Recent Updates**: SPA routing fix, deployment pipeline improvements

## Development Workflow

### Local Development
```bash
# Clone repository
git clone https://github.com/fanaticodev/fanatico-sites.git

# Navigate to site
cd sites/fanatico.pro

# Install dependencies
npm install

# Start dev server
npm run dev
```

### Building for Production
```bash
# Build site
npm run build

# Test build locally
docker build -t test .
docker run -p 8080:80 test
```

### Deployment
```bash
# Push to main branch
git push origin main

# GitHub Actions automatically:
# 1. Pulls code to server
# 2. Builds changed sites
# 3. Creates Docker images
# 4. Restarts containers
```

## Container Configuration

### Docker Networks
- **web-network**: External access via NGINX
- **sites-internal**: Inter-site communication

### Environment Variables
Each site has its own `.env` file (not in Git):
```env
NODE_ENV=production
API_URL=https://api.fanati.co
DATABASE_URL=mysql://user:pass@db:3306/dbname
```

### Health Checks
```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## Monitoring

### Container Status
```bash
docker ps --format "table {{.Names}}\t{{.Status}}" | grep sites_
```

### Resource Usage
```bash
docker stats --no-stream | grep sites_
```

### Logs
```bash
# Individual site
docker logs sites_fanatico_pro_app_1 --tail 100

# All sites
for site in $(docker ps --format '{{.Names}}' | grep sites_); do
  echo "=== $site ==="
  docker logs $site --tail 10
done
```

## SSL Certificates

### Domains Covered
All *.fanatico domains plus partners.fanati.co

### Certificate Management
- **Provider**: Let's Encrypt
- **Method**: Certbot via NGINX container
- **Renewal**: Automatic (cron job)
- **Location**: `/home/sebastian/certbot/`

### Manual Renewal
```bash
docker exec nginx_proxy certbot renew
docker restart nginx_proxy
```

## Performance Optimization

### Static Sites
- NGINX caching headers
- Gzip compression
- Minified assets
- CDN-ready structure

### React Applications
- Code splitting
- Lazy loading
- Tree shaking
- Optimized builds

### Node.js Applications
- PM2 process management
- Cluster mode
- Memory limits
- Graceful shutdown

## Backup Strategy

### What's Backed Up
- Source code: GitHub
- Databases: Daily dumps
- User uploads: File sync
- Configuration: Version controlled

### Recovery Points
- Code: Any Git commit
- Database: Last 30 days
- Files: Last 7 days

## Security Measures

### Application Security
- Input validation
- SQL injection prevention
- XSS protection
- CSRF tokens
- Rate limiting

### Infrastructure Security
- HTTPS only
- Security headers
- Container isolation
- Regular updates
- Vulnerability scanning

## Maintenance

### Regular Tasks
- Update dependencies monthly
- Security patches immediately
- Performance monitoring daily
- Backup verification weekly

### Update Procedure
```bash
# Update specific site
cd sites/[site-name]
npm update
npm audit fix
npm run build
docker build -t [site]:new .
docker-compose up -d [site]
```

## Troubleshooting

### Site Not Loading
1. Check container status
2. Review NGINX logs
3. Verify DNS resolution
4. Test backend health

### Build Failures
1. Check Node version
2. Clear npm cache
3. Verify dependencies
4. Review build logs

### Performance Issues
1. Monitor resource usage
2. Check database queries
3. Review application logs
4. Analyze network traffic## Recent Updates (November 2025)

### Infrastructure Improvements
- ✅ All 11 fanatico.* sites deployed and operational
- ✅ fanatico.pro prepared for new codebase (Aviator archived to branch)
- ✅ fanatico.vip migrated from separate repository to monorepo
- ✅ fanatico.cash SPA routing fixed (browser reload on /game now works)
- ✅ Deployment pipeline improved for fanatico.cash

### Repository Organization
- **Monorepo (fanatico-sites)**: Contains all 11 fanatico.* domain sites
- **Separate Repositories**:
  - [fanatico-cash](https://github.com/fanaticodev/fanatico-cash) - Aviator crash game
  - [partners-fanati-co](https://github.com/fanaticodev/partners-fanati-co) - Partner portal
  - [multi-sites](https://github.com/fanaticodev/multi-sites) - Multi-domain framework
  - [fanatico-documentation](https://github.com/fanaticodev/fanatico-documentation) - This documentation

### Container Reorganization (November 24, 2025)
- Moved aviator-crash containers → sites group
- Moved tron-pix-app → billing group
- Renamed abuse_processing → compliance group
- Moved partnersfanatico containers → sites group
- Consolidated all site containers for better Docker UI organization
