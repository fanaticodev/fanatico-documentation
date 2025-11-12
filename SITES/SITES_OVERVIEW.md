# Fanatico Sites Overview

## Production Sites

The Fanatico network consists of 11+ sites hosted on Fremont2 server, all managed through a monorepo and deployed via Docker containers.

## Sites Directory

| Domain | Type | Technology | Container | Status |
|--------|------|------------|-----------|--------|
| **fanatico.pro** | Trading Platform | React + TypeScript + Vite | sites_fanatico_pro_app_1 | ✅ Active |
| **fanatico.bet** | Betting Platform | Node.js + MariaDB | sites_fanatico_bet_app_1 | ✅ Active |
| **fanatico.me** | SSO Portal | Node.js + Passkey Auth | sites_fanatico_me_app_1 | ✅ Active |
| **fanatico.cash** | Gaming Platform | Static + Aviator Backend | sites_aviator_backend_1 | ✅ Active |
| **fanatico.vip** | Static Site | HTML/CSS/JS | sites_fanatico_vip_app_1 | ✅ Active |
| **fanatico.xyz** | Static Site | HTML/CSS/JS | sites_fanatico_xyz_app_1 | ✅ Active |
| **fanatico.social** | Social Platform | HTML/CSS/JS | sites_fanatico_social_app_1 | ✅ Active |
| **fanatico.chat** | Chat Interface | HTML/CSS/JS | sites_fanatico_chat_app_1 | ✅ Active |
| **fanatico.club** | Club Portal | HTML/CSS/JS | sites_fanatico_club_app_1 | ✅ Active |
| **fanatico.games** | Gaming Hub | HTML/CSS/JS | sites_fanatico_games_app_1 | ✅ Active |
| **fanatico.app** | Application Portal | HTML/CSS/JS | sites_fanatico_app_app_1 | ✅ Active |
| **partners.fanati.co** | Partner Portal | React + TypeScript | sites_partners_fanati_co_app_1 | ✅ Active |

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

### fanatico.pro - Professional Trading
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **Features**: Real-time data, charts, trading interface
- **Container**: NGINX Alpine serving static build

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

### fanatico.cash - Gaming Platform
- **Frontend**: Static site
- **Backend**: Aviator game server (Node.js)
- **Database**: MongoDB
- **WebSocket**: Socket.IO
- **Features**: Crash game, FCO tokens, multiplayer
- **Containers**: NGINX + Node.js + MongoDB

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
4. Analyze network traffic