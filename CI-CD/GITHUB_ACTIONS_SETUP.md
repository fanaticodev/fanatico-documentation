# GitHub Actions Setup Guide

## Overview

This guide covers the setup and configuration of GitHub Actions for the Fanatico Sites CI/CD pipeline.

## Prerequisites

- GitHub repository with admin access
- SSH access to production server (Fremont2)
- Docker and Docker Compose on production server
- `sites` user configured on server

## GitHub Secrets Configuration

### Required Secrets

Navigate to: Settings → Secrets and variables → Actions

| Secret Name | Value | Description |
|------------|-------|-------------|
| `FREMONT2_HOST` | `185.34.201.34` | Production server IP |
| `FREMONT2_USER` | `sites` | SSH user for deployment |
| `FREMONT2_SSH_KEY` | `<private key>` | ED25519 SSH private key |

### Adding Secrets

1. Go to repository settings
2. Click "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Enter name and value
5. Click "Add secret"

## SSH Key Setup

### Generate SSH Key Pair

```bash
# Generate ED25519 key without passphrase
ssh-keygen -t ed25519 -C "github-actions-fanatico-sites" -f github-actions-sites-key
# Press ENTER for no passphrase
```

### Server Configuration

1. Add public key to `/home/sites/.ssh/authorized_keys`:
```
command="/home/sites/github-deploy.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 <public-key>
```

2. Create command whitelist script at `/home/sites/github-deploy.sh`
3. Set permissions:
```bash
chmod 755 /home/sites/github-deploy.sh
chmod 600 /home/sites/.ssh/authorized_keys
chown sites:sites /home/sites/.ssh/authorized_keys
```

## Workflow File

### Location
`.github/workflows/deploy-production.yml`

### Basic Structure
```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
    paths:
      - 'sites/**'
      - 'infrastructure/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.FREMONT2_SSH_KEY }}
      # ... deployment steps
```

## Testing the Setup

### Manual Trigger
1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"
4. Select branch and run

### Verify Connection
```yaml
- name: Test SSH Connection
  run: |
    ssh ${{ secrets.FREMONT2_USER }}@${{ secrets.FREMONT2_HOST }} "echo 'Connected successfully'"
```

## Security Considerations

### Key Security
- Never commit private keys
- Use GitHub Secrets for sensitive data
- Rotate keys periodically
- Use ED25519 keys (more secure than RSA)

### Access Restrictions
- Restrict SSH user permissions
- Use command whitelist
- Disable password authentication
- Log all deployment attempts

## Troubleshooting

### Common Issues

#### Permission Denied
- Verify `FREMONT2_USER` is set to `sites`
- Check SSH key format (must have line breaks)
- Ensure public key is in authorized_keys

#### Exit Code 255
- SSH connection failure
- Check server IP in `FREMONT2_HOST`
- Verify server is accessible

#### Command Not Found
- Command not in whitelist
- Add to `/home/sites/github-deploy.sh`

### Debug Mode

Add verbose SSH output:
```yaml
- name: Debug SSH
  run: |
    ssh -v ${{ secrets.FREMONT2_USER }}@${{ secrets.FREMONT2_HOST }} "command"
```

## Best Practices

1. **Use Path Filters**: Only trigger on relevant changes
2. **Conditional Steps**: Skip unnecessary builds
3. **Health Checks**: Verify deployment success
4. **Cleanup**: Remove old Docker resources
5. **Notifications**: Alert on failures

## References

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [webfactory/ssh-agent](https://github.com/webfactory/ssh-agent)
- [SSH Key Management](https://docs.github.com/authentication/connecting-to-github-with-ssh)