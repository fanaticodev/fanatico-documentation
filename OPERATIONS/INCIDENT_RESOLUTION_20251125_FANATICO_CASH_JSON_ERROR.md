# Incident Resolution Report: Fanatico.cash JSON Parse Error
## Date: November 25, 2025

## Incident Overview
**Service Affected**: fanatico.cash (Aviator Crash Game)
**Incident Type**: Frontend API Integration Error
**Severity**: High - Login functionality completely broken
**Duration**: ~2 hours (discovered and fixed on Nov 25, 2025)
**Impact**: Users unable to login, receiving "Unexpected token '<', '<html> <h'... is not valid JSON" error

## Timeline
- **04:30 UTC**: SPA routing fix deployed (nginx configuration)
- **05:37 UTC**: Deployment workflow fixes merged and deployed
- **06:30 UTC**: User reported JSON parse error on login
- **06:45 UTC**: Root cause identified - frontend using incorrect API URL
- **07:03 UTC**: Fix applied and verified
- **07:10 UTC**: Deployment workflow updated to prevent recurrence

## Root Cause Analysis

### Primary Issue
The frontend Docker container was built without proper environment variables, causing React to use undefined/default values for API endpoints. This resulted in the frontend attempting to call non-existent endpoints, receiving HTML error pages instead of JSON responses.

### Contributing Factors
1. **Multi-stage Docker Build**: The Dockerfile rebuilds the React app inside the container during the build stage
2. **Missing Build Arguments**: The CI/CD pipeline didn't pass environment variables as Docker build arguments
3. **React Build-Time Variables**: React environment variables are embedded at build time, not runtime

### Technical Details
```javascript
// Frontend was trying to call:
fetch(`${process.env.REACT_APP_API_URL}/users/login`)
// But REACT_APP_API_URL was undefined during build

// Resulting in:
fetch(`undefined/users/login`)  // Returns 404 HTML page
```

## Resolution

### Immediate Fix
1. **Rebuilt frontend with correct build arguments**:
```bash
docker build --no-cache \
  --build-arg REACT_APP_API_URL=https://fanatico.cash/api \
  --build-arg REACT_APP_WS_URL=https://fanatico.cash \
  --build-arg REACT_APP_APP_KEY=crash-0.1.0 \
  --build-arg REACT_APP_DEBUG=false \
  -t sites_aviator_frontend .
```

2. **Restarted container with properly built image**:
```bash
docker stop sites_aviator_frontend_1
docker rm sites_aviator_frontend_1
docker run -d --name sites_aviator_frontend_1 \
  --network web-network \
  -p 127.0.0.1:3002:80 \
  sites_aviator_frontend
```

### Permanent Fix
Updated `.github/workflows/deploy-production.yml` to include build arguments:
```yaml
docker build \
  --build-arg REACT_APP_API_URL=https://fanatico.cash/api \
  --build-arg REACT_APP_WS_URL=https://fanatico.cash \
  --build-arg REACT_APP_APP_KEY=crash-0.1.0 \
  --build-arg REACT_APP_DEBUG=false \
  -t aviator-crash_aviator_frontend .
```

## Verification Steps
1. **Check built JavaScript contains correct API URL**:
```bash
docker exec sites_aviator_frontend_1 \
  grep -o '"https://fanatico.cash/api"' \
  /usr/share/nginx/html/static/js/main.*.js
```

2. **Test login API directly**:
```bash
curl -X POST https://fanatico.cash/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"clicker","password":"clicker123"}'
```

3. **Verify through browser**: Login at https://fanatico.cash

## Lessons Learned

### What Went Well
- Quick identification of root cause through systematic debugging
- Backend services were functioning correctly throughout
- MongoDB and NGINX configurations were properly set up

### What Could Be Improved
1. **CI/CD Pipeline**: Should validate that environment variables are properly passed to Docker builds
2. **Health Checks**: Add frontend configuration validation to deployment health checks
3. **Documentation**: Clearly document build argument requirements for Docker images
4. **Testing**: Add integration tests that verify API endpoints are correctly configured

## Prevention Measures

### Implemented
1. ✅ Updated deployment workflow with required build arguments
2. ✅ Documented the issue and solution in multiple locations
3. ✅ Fixed docker-compose.prod.yml already had correct configuration

### Recommended
1. **Environment Validation**: Add a startup script that validates critical environment variables
2. **Build-Time Checks**: Implement build-time validation of API configuration
3. **Monitoring**: Add alerts for JSON parse errors in frontend
4. **Deployment Checklist**: Create a checklist for validating frontend builds

## Related Issues
- Previous MongoDB connection issues (resolved Nov 24, 2025)
- SPA routing 404 errors (fixed with nginx configuration)
- Deployment workflow ContainerConfig errors (fixed in same session)

## Documentation Updates
- Created: `/home/sebastian/sites/fanatico.cash/JSON_ERROR_FIX_20251125.md`
- Created: `/home/sebastian/sites/fanatico.cash/JSON_ERROR_FIX_REBUILD_20251125.md`
- Updated: `.github/workflows/deploy-production.yml` (commit 3d0a5b4)

## Current Status
✅ **RESOLVED** - Service fully operational
- Login functionality restored
- All API endpoints responding correctly
- Deployment pipeline fixed for future deployments

---
*Report compiled by Claude Code*
*Incident resolved on November 25, 2025*