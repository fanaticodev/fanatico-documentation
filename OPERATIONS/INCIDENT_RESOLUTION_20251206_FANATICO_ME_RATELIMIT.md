# Incident Resolution: Fanatico.me Rate Limit Warnings

**Date**: December 6, 2025
**Service**: fanatico.me (sites_fanatico_me_app_1)
**Status**: Resolved
**Duration**: ~20 minutes

## Summary

The fanatico.me container was flooding logs with `[WEBAUTHN:SECURITY] Rate limit exceeded` warnings every 30 seconds. The container was healthy and functional, but the excessive logging was caused by Docker healthchecks triggering the application's rate limiter.

## Root Cause Analysis

### Issue 1: Healthcheck Rate Limiting
- Docker healthcheck hit `/health` endpoint every 30 seconds
- `generalRateLimit` middleware allowed only 20 requests per 15 minutes
- Healthcheck rate (30 requests/15min) exceeded limit (20 requests/15min)
- Result: Rate limit warning logged every 30 seconds

### Issue 2: Healthcheck IPv6 Resolution
- Healthcheck used `localhost` which resolved to `::1` (IPv6)
- Node.js server only listened on `0.0.0.0` (IPv4)
- Result: Healthcheck connection refused, container marked "unhealthy"

## Resolution

### Fix 1: Skip Rate Limiting for Health Endpoints

**File**: `/home/sebastian/sites/fanatico.me/middleware/security.js`

```javascript
skip: (req) => {
    // Skip rate limiting for local development
    if (process.env.NODE_ENV === 'development' &&
        (req.ip === '127.0.0.1' || req.ip === '::1')) {
        return true;
    }
    // Skip rate limiting for health check endpoints (Docker healthcheck)
    if (req.path === '/health' || req.path === '/api/webauthn/health') {
        return true;
    }
    return false;
},
```

### Fix 2: Use IPv4 Address in Healthcheck

**File**: `/home/sebastian/sites/fanatico.me/docker-compose.yml`

```yaml
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get('http://127.0.0.1:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); });"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

## Additional Fixes During Recovery

### NGINX Network Connectivity
During container recreation, nginx_proxy lost network connections:
- Reconnected to `mailcow_mailcow-network`
- Reconnected to `app-network`

Commands used:
```bash
docker network connect mailcow_mailcow-network nginx_proxy
docker network connect app-network nginx_proxy
docker restart nginx_proxy
```

## Verification

```bash
# Check container health
docker ps --filter "name=sites_fanatico_me_app_1" --format "{{.Status}}"
# Output: Up X minutes (healthy)

# Verify no rate limit warnings
docker logs sites_fanatico_me_app_1 --since "5m" 2>&1 | grep "Rate limit"
# Output: (empty - no warnings)

# Test site accessibility
curl -sI https://fanatico.me/ | head -3
# HTTP/2 200
```

## Files Modified

| File | Change |
|------|--------|
| `middleware/security.js` | Added skip for `/health` endpoints in rate limiter |
| `docker-compose.yml` | Changed healthcheck from `localhost` to `127.0.0.1` |

## Lessons Learned

1. **Health endpoints should bypass rate limiting** - Internal health checks (Docker, Kubernetes, load balancers) should not be subject to application rate limits
2. **Use IPv4 explicitly in Alpine containers** - Alpine Linux resolves `localhost` to IPv6 first, which may not work if the application only binds to IPv4
3. **Document network dependencies** - nginx_proxy requires connections to multiple Docker networks; these can be lost on restart

## Prevention

- Added health endpoint paths to rate limiter skip list
- Updated docker-compose.yml with IPv4-specific healthcheck
- Consider adding network reconnection to nginx startup scripts

## Related Documentation

- `/home/sebastian/sites/fanatico.me/README.md`
- `/home/sebastian/documentation/OPERATIONS/INCIDENT_RESOLUTION_20251104_AVIATOR_HEALTHCHECK.md` (similar IPv6 issue)
