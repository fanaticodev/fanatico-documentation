# Fanatico.cash Deployment Pipeline
## Last Updated: November 25, 2025

## Overview
Fanatico.cash (Aviator Crash Game) uses a dedicated GitHub Actions workflow for automated deployment to Fremont2 server. The application consists of a React frontend, Node.js backend, and MongoDB database.

## Repository
- **GitHub**: https://github.com/fanaticodev/fanatico-cash
- **Default Branch**: main
- **Deployment Trigger**: Push to main branch

## Architecture
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   React SPA     │────▶│  Node.js API    │────▶│    MongoDB      │
│  (Frontend)     │     │   (Backend)     │     │   (Database)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
    Port 3002              Port 5001              Port 27017
    ↓                      ↓                      (Internal)
┌──────────────────────────────────────┐
│         NGINX Reverse Proxy          │
│        https://fanatico.cash         │
└──────────────────────────────────────┘
```

## Deployment Workflow

### File Location
`.github/workflows/deploy-production.yml`

### Workflow Steps
1. **Trigger**: Push to main branch
2. **SSH to Fremont2**: Connect as sebastian@185.34.201.34
3. **Pull Latest Code**: Git fetch and reset to origin/main
4. **Install Dependencies**: npm ci for both frontend and backend
5. **Build Frontend Docker Image** (with build arguments):
   ```bash
   docker build \
     --build-arg REACT_APP_API_URL=https://fanatico.cash/api \
     --build-arg REACT_APP_WS_URL=https://fanatico.cash \
     --build-arg REACT_APP_APP_KEY=crash-0.1.0 \
     --build-arg REACT_APP_DEBUG=false \
     -t aviator-crash_aviator_frontend .
   ```
6. **Build Backend Docker Image**: Using docker-compose
7. **Deploy Containers**: Stop old containers, start new ones
8. **Health Checks**: Verify services are running

### Critical Configuration

#### Environment Variables (Build-Time)
The frontend requires these environment variables at **build time**, not runtime:
- `REACT_APP_API_URL`: API endpoint (https://fanatico.cash/api)
- `REACT_APP_WS_URL`: WebSocket URL (https://fanatico.cash)
- `REACT_APP_APP_KEY`: Application key (crash-0.1.0)
- `REACT_APP_DEBUG`: Debug mode (false)

#### Docker Networks
- **web-network**: For NGINX access
- **sites-internal**: For backend services communication

## Container Management

### Container Names
- Frontend: `sites_aviator_frontend_1`
- Backend: `sites_aviator_backend_1`
- MongoDB: `sites_aviator_mongo_1`

### Port Mappings
- Frontend: 127.0.0.1:3002 → 80 (container)
- Backend: 127.0.0.1:5001 → 5001 (container)
- MongoDB: Internal only (27017)

## Common Issues and Solutions

### Issue 1: JSON Parse Error on Login
**Symptom**: "Unexpected token '<', '<html>...' is not valid JSON"
**Cause**: Frontend built without proper API URL
**Solution**: Rebuild with correct build arguments (see workflow above)

### Issue 2: ContainerConfig Error
**Symptom**: Deployment fails with "ContainerConfig" error
**Cause**: Container already exists
**Solution**: Stop and remove container before creating new one

### Issue 3: SPA Routing 404
**Symptom**: Browser reload on /game returns 404
**Cause**: NGINX not configured for SPA routing
**Solution**: Add nginx-frontend.conf with try_files directive

## Manual Deployment

If automatic deployment fails, use these commands:

```bash
# SSH to server
ssh sebastian@185.34.201.34

# Navigate to project
cd /home/sebastian/sites/fanatico.cash/Aviator-Crash

# Pull latest code
git pull origin main

# Build frontend with correct arguments
docker build --no-cache \
  --build-arg REACT_APP_API_URL=https://fanatico.cash/api \
  --build-arg REACT_APP_WS_URL=https://fanatico.cash \
  --build-arg REACT_APP_APP_KEY=crash-0.1.0 \
  --build-arg REACT_APP_DEBUG=false \
  -t sites_aviator_frontend .

# Restart frontend
docker stop sites_aviator_frontend_1
docker rm sites_aviator_frontend_1
docker run -d --name sites_aviator_frontend_1 \
  --network web-network \
  -p 127.0.0.1:3002:80 \
  sites_aviator_frontend

# Rebuild and restart backend
cd /home/sebastian/sites
docker-compose -f docker-compose-dynamic-complete.yml up -d --build aviator_backend
```

## Monitoring and Verification

### Health Checks
```bash
# Check container status
docker ps | grep aviator

# Test backend health
curl http://localhost:5001/health

# Test login API
curl -X POST https://fanatico.cash/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"clicker","password":"clicker123"}'

# Verify frontend has correct API URL
docker exec sites_aviator_frontend_1 \
  grep -o '"https://fanatico.cash/api"' \
  /usr/share/nginx/html/static/js/main.*.js
```

### Logs
```bash
# Frontend logs
docker logs sites_aviator_frontend_1

# Backend logs
docker logs sites_aviator_backend_1

# MongoDB logs
docker logs sites_aviator_mongo_1
```

## Recent Updates

### November 25, 2025
- Fixed JSON parse error by adding build arguments to deployment workflow
- Resolved SPA routing issues with custom nginx configuration
- Fixed ContainerConfig errors in deployment pipeline
- Updated workflow to properly handle frontend container lifecycle

### November 24, 2025
- Fixed MongoDB connection issues
- Resolved network isolation between containers
- Cleaned up duplicate MongoDB containers

## Security Considerations
1. **Secrets Management**: SSH key stored in GitHub Secrets
2. **Network Security**: All services bound to localhost except through NGINX
3. **CORS Configuration**: Restricted to fanatico.cash domains
4. **JWT Tokens**: Secure HTTP-only cookies with SameSite=Lax

## Rollback Procedure
```bash
# Get previous commit
git log --oneline -5

# Reset to previous commit
git reset --hard <commit-hash>

# Rebuild and deploy
# Follow manual deployment steps above
```

## Contact
- **Repository**: https://github.com/fanaticodev/fanatico-cash
- **Production URL**: https://fanatico.cash
- **Server**: Fremont2 (185.34.201.34)

---
*Documentation maintained by Fanatico Development Team*