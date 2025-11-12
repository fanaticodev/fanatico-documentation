# Common Issues and Solutions

## GitHub Actions Deployment Issues

### Issue: Workflow fails with exit code 255

**Symptoms:**
- GitHub Actions workflow fails immediately
- Exit code 255 in logs
- No detailed error message

**Causes:**
- SSH connection failure
- Incorrect secrets configuration
- Wrong username in FREMONT2_USER

**Solution:**
1. Verify `FREMONT2_USER` is set to `sites` (not `sebastian`)
2. Check `FREMONT2_HOST` is `185.34.201.34`
3. Ensure SSH key has proper line breaks
4. Test connection manually:
```bash
ssh -i /path/to/key sites@185.34.201.34 "echo test"
```

### Issue: Command rejected by whitelist

**Symptoms:**
- SSH connects successfully
- Command fails with "Command not allowed"
- Error in syslog: "REJECTED: Unauthorized command"

**Solution:**
1. Check exact command in logs:
```bash
sudo grep "REJECTED" /var/log/syslog | tail -5
```
2. Add command to `/home/sites/github-deploy.sh`
3. Test manually before pushing

### Issue: Docker build fails

**Symptoms:**
- npm install or build errors
- Docker image build failures
- Out of space errors

**Solution:**
1. Check disk space:
```bash
df -h /mnt/nvm
docker system df
```
2. Clean up if needed:
```bash
docker system prune -af
```
3. Verify package.json dependencies
4. Check Node.js version compatibility

## Container Issues

### Issue: Container keeps restarting

**Symptoms:**
- Container in restart loop
- Status shows "Restarting (X) Y seconds ago"

**Solution:**
1. Check logs:
```bash
docker logs [container-name] --tail 50
```
2. Common causes:
   - Port already in use
   - Configuration error
   - Missing environment variables
   - Database connection failure

### Issue: Container won't start

**Symptoms:**
- Container exits immediately
- Status shows "Exited (X)"

**Solution:**
1. Check exit code:
   - 0: Normal exit
   - 1: General errors
   - 125: Docker daemon error
   - 126: Container command not executable
   - 127: Container command not found

2. Debug steps:
```bash
# Check logs
docker logs [container-name]

# Run interactively
docker run -it [image] /bin/sh

# Check configuration
docker-compose config
```

### Issue: Container can't connect to database

**Symptoms:**
- Connection refused errors
- Timeout errors
- Authentication failures

**Solution:**
1. Verify database is running:
```bash
docker ps | grep [database-name]
```
2. Check network connectivity:
```bash
docker exec [app-container] ping [db-container]
```
3. Verify credentials:
```bash
docker exec [app-container] env | grep DB_
```
4. Test connection:
```bash
docker exec [db-container] psql -U [user] -d [database] -c "SELECT 1"
```

## Network Issues

### Issue: NGINX returns 502 Bad Gateway

**Symptoms:**
- Browser shows 502 error
- Backend container is running
- Site inaccessible

**Solution:**
1. Check if backend is healthy:
```bash
docker ps | grep [backend-name]
docker inspect [backend-name] | grep -i health
```
2. Test from NGINX container:
```bash
docker exec nginx_proxy curl http://[backend]:80/
```
3. Verify network configuration:
```bash
docker network inspect web-network
```
4. Restart NGINX:
```bash
docker restart nginx_proxy
```

### Issue: SSL certificate errors

**Symptoms:**
- Browser warning about certificate
- HTTPS not working
- Certificate expired message

**Solution:**
1. Check certificate status:
```bash
docker exec nginx_proxy certbot certificates
```
2. Renew certificates:
```bash
docker exec nginx_proxy certbot renew
```
3. Restart NGINX:
```bash
docker restart nginx_proxy
```

## Performance Issues

### Issue: Site loading slowly

**Symptoms:**
- Long page load times
- Timeouts
- High server load

**Solution:**
1. Check resource usage:
```bash
docker stats --no-stream
htop
```
2. Identify bottlenecks:
   - CPU: Check for runaway processes
   - Memory: Look for memory leaks
   - Disk I/O: Check for high I/O wait
   - Network: Monitor bandwidth usage

3. Optimize:
```bash
# Restart problematic containers
docker restart [container-name]

# Clean up resources
docker system prune -af

# Check logs for errors
docker logs [container-name] | grep ERROR
```

## SSH Access Issues

### Issue: Can't SSH to server

**Symptoms:**
- Connection timeout
- Permission denied
- No route to host

**Solution:**
1. Check if you're using correct user and key:
```bash
ssh -v sebastian@185.34.201.34
```
2. Verify key permissions:
```bash
chmod 600 ~/.ssh/id_ed25519
```
3. Check if banned by fail2ban:
```bash
# On server
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip [your-ip]
```

### Issue: SSH key not working

**Symptoms:**
- Permission denied (publickey)
- Key refused

**Solution:**
1. Verify key is in authorized_keys:
```bash
cat ~/.ssh/authorized_keys | grep [your-key-comment]
```
2. Check file permissions:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```
3. Test with verbose output:
```bash
ssh -vvv user@server
```

## Deployment Issues

### Issue: Changes not appearing after deployment

**Symptoms:**
- GitHub Actions shows success
- Old version still showing
- Cache issues

**Solution:**
1. Clear browser cache (Ctrl+F5)
2. Check if correct container is running:
```bash
docker ps | grep [site-name]
docker inspect [container] | grep Created
```
3. Verify files were synced:
```bash
ls -la /home/sebastian/sites/[site-name]/dist/
```
4. Rebuild without cache:
```bash
docker-compose build --no-cache [service]
docker-compose up -d [service]
```

### Issue: Deployment partially fails

**Symptoms:**
- Some sites updated, others not
- Incomplete deployment

**Solution:**
1. Check which sites changed:
```bash
cd /home/sebastian/git-repos/fanatico-sites
git diff --name-only HEAD~1 HEAD
```
2. Manually trigger missing builds:
```bash
cd sites/[site-name]
npm ci && npm run build
rsync -av dist/ /home/sebastian/sites/[site-name]/dist/
```
3. Restart affected containers:
```bash
docker-compose restart [service-name]
```

## Monitoring Issues

### Issue: Grafana shows no data

**Symptoms:**
- Empty graphs
- "No data" messages
- Metrics missing

**Solution:**
1. Check Prometheus is running:
```bash
docker ps | grep prometheus
```
2. Verify data source configuration in Grafana
3. Check correct Prometheus instance:
   - system-prometheus: Port 9091 (container metrics)
   - ping-prometheus: Port 9090 (API monitoring)
   - trace-prometheus: Port 9094 (blockchain)
   - trade-prometheus: Port 9095 (trading)

4. Test query directly in Prometheus:
```bash
curl http://localhost:9090/api/v1/query?query=up
```

## Quick Diagnostic Commands

```bash
# System health
df -h
free -m
uptime
docker ps --format "table {{.Names}}\t{{.Status}}"

# Recent errors
docker ps -a --filter "status=exited"
sudo journalctl -xe | tail -50
sudo grep ERROR /var/log/syslog | tail -20

# Network connectivity
ss -tulpn
iptables -L -n
docker network ls

# Resource usage
docker stats --no-stream
iostat -x 1
netstat -i
```

## Escalation Path

1. Check documentation in this repository
2. Review recent incident reports
3. Check GitHub Actions logs
4. Monitor server metrics
5. Contact system administrator if unresolved