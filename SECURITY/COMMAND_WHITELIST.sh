#!/bin/bash
#
# Restricted Deployment Script for GitHub Actions (sites user)
#
# This script whitelists specific commands that GitHub Actions can execute.
# Any command not explicitly listed here will be rejected.
#

# Log all attempts
logger -t github-sites "SSH connection from ${SSH_CLIENT} - Original command: ${SSH_ORIGINAL_COMMAND}"

# If no command specified, reject (interactive shell not allowed for GitHub Actions key)
if [ -z "$SSH_ORIGINAL_COMMAND" ]; then
    echo "Interactive shell not allowed for GitHub Actions deployment key"
    logger -t github-sites "REJECTED: Interactive shell attempt from ${SSH_CLIENT}"
    exit 1
fi

# Whitelist of allowed commands
# Add new commands here as needed for deployment workflows
case "$SSH_ORIGINAL_COMMAND" in
    # System check (used by GitHub Actions to verify connection)
    "[ -d .git ]"|"[ -f \"package.json\" ]"|"[ -f \"package-lock.json\" ]"|"[ -d \"dist\" ]"|"[ -f /home/sebastian/git-repos/fanatico-sites/sites/fanatico.pro/package.json ]")
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    # Git operations in fanatico-sites repository
    "git pull origin main")
        cd /home/sebastian/git-repos/fanatico-sites && git pull origin main
        ;;

    "cd /home/sebastian/git-repos/fanatico-sites && git fetch origin")
        cd /home/sebastian/git-repos/fanatico-sites && git fetch origin
        ;;

    "cd /home/sebastian/git-repos/fanatico-sites && git status")
        cd /home/sebastian/git-repos/fanatico-sites && git status
        ;;

    "cd /home/sebastian/git-repos/fanatico-sites && git diff --name-only HEAD~1 HEAD")
        cd /home/sebastian/git-repos/fanatico-sites
        git diff --name-only HEAD~1 HEAD
        ;;

    "cd /home/sebastian/git-repos/fanatico-sites && git rev-parse HEAD")
        cd /home/sebastian/git-repos/fanatico-sites
        git rev-parse HEAD
        ;;

    # Build operations for any site
    "cd /home/sebastian/git-repos/fanatico-sites/sites/"*" && npm ci && npm run build")
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    "cd /home/sebastian/git-repos/fanatico-sites/sites/"*" && npm ci")
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    "cd /home/sebastian/git-repos/fanatico-sites/sites/"*" && npm run build")
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    # Rsync operations - from git-repos to production sites
    rsync\ -av\ --delete\ *)
        # Only allow rsync from git-repos to sites
        if echo "$SSH_ORIGINAL_COMMAND" | grep -q "^rsync -av --delete /home/sebastian/git-repos/fanatico-sites/sites/.*/dist/ /home/sebastian/sites/.*/dist/"; then
            eval "$SSH_ORIGINAL_COMMAND"
        else
            echo "ERROR: Rsync only allowed from git-repos to sites directories"
            logger -t github-sites "REJECTED: Invalid rsync path from ${SSH_CLIENT}: ${SSH_ORIGINAL_COMMAND}"
            exit 1
        fi
        ;;

    # Docker operations in production directory
    "cd /home/sebastian/sites && docker-compose -f docker-compose-dynamic-complete.yml build")
        cd /home/sebastian/sites
        docker-compose -f docker-compose-dynamic-complete.yml build
        ;;

    "cd /home/sebastian/sites && docker-compose -f docker-compose-dynamic-complete.yml build "*)
        cd /home/sebastian/sites
        SERVICE=$(echo "$SSH_ORIGINAL_COMMAND" | sed 's/.*build //')
        docker-compose -f docker-compose-dynamic-complete.yml build "$SERVICE"
        ;;

    "cd /home/sebastian/sites && docker-compose -f docker-compose-dynamic-complete.yml up -d")
        cd /home/sebastian/sites
        docker-compose -f docker-compose-dynamic-complete.yml up -d
        ;;

    "cd /home/sebastian/sites && docker-compose -f docker-compose-dynamic-complete.yml up -d "*)
        cd /home/sebastian/sites
        SERVICE=$(echo "$SSH_ORIGINAL_COMMAND" | sed 's/.*up -d //')
        docker-compose -f docker-compose-dynamic-complete.yml up -d "$SERVICE"
        ;;

    "cd /home/sebastian/sites && docker-compose -f docker-compose-dynamic-complete.yml restart "*)
        cd /home/sebastian/sites
        SERVICE=$(echo "$SSH_ORIGINAL_COMMAND" | sed 's/.*restart //')
        docker-compose -f docker-compose-dynamic-complete.yml restart "$SERVICE"
        ;;

    # Docker status checks
    "docker ps")
        docker ps
        ;;

    "docker ps --format "*)
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    "docker logs "*)
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    # Docker cleanup
    "docker system prune -f")
        docker system prune -f
        ;;

    # Health check commands
    "curl -I https://"*)
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    curl\ *)
        eval "$SSH_ORIGINAL_COMMAND"
        ;;

    # Test connectivity
    "echo 'SSH connection successful'")
        echo 'SSH connection successful'
        ;;

    # Allow multi-command chains used by GitHub Actions
    *" && "*)
        if echo "$SSH_ORIGINAL_COMMAND" | grep -qE "^cd .* && (git|npm|docker|rsync|curl)"; then
            eval "$SSH_ORIGINAL_COMMAND"
        else
            echo "ERROR: Chained command not in whitelist: $SSH_ORIGINAL_COMMAND"
            logger -t github-sites "REJECTED: Unauthorized chained command from ${SSH_CLIENT}: ${SSH_ORIGINAL_COMMAND}"
            exit 1
        fi
        ;;

    # Catch-all: reject anything not explicitly whitelisted
    *)
        echo "ERROR: Command not allowed: $SSH_ORIGINAL_COMMAND"
        logger -t github-sites "REJECTED: Unauthorized command from ${SSH_CLIENT}: ${SSH_ORIGINAL_COMMAND}"
        exit 1
        ;;
esac

# Log successful execution
logger -t github-sites "SUCCESS: Executed command from ${SSH_CLIENT}: ${SSH_ORIGINAL_COMMAND}"
exit 0

    # Package.json checks for specific sites
    "[ -f /home/sebastian/git-repos/fanatico-sites/sites/"*"/package.json ]")
        eval "$SSH_ORIGINAL_COMMAND"
        ;;
