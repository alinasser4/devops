#!/bin/bash

# Deployment script
# This script deploys the code to the test environment

set -e

echo "=========================================="
echo "Starting Deployment Process"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEPLOY_DIR="./deploy"
SOURCE_DIR="./php-app"
COMPOSE_FILE="docker-compose.test.yml"

# Check if deploy directory exists
if [ ! -d "$DEPLOY_DIR" ]; then
    echo -e "${RED}✗ Deploy directory does not exist. Run build.sh first.${NC}"
    exit 1
fi

# Copy application files to deploy directory
echo -e "${YELLOW}Copying application files to deploy directory...${NC}"
cp -r "$SOURCE_DIR"/* "$DEPLOY_DIR/" || {
    echo -e "${RED}✗ Failed to copy files${NC}"
    exit 1
}

# Set proper permissions
echo -e "${YELLOW}Setting file permissions...${NC}"
chmod -R 755 "$DEPLOY_DIR"

# Restart PHP container to pick up changes
echo -e "${YELLOW}Restarting PHP container...${NC}"
docker-compose -f "$COMPOSE_FILE" restart php-apache || {
    echo -e "${RED}✗ Failed to restart PHP container${NC}"
    exit 1
}

# Wait a moment for container to restart
sleep 5

echo -e "${GREEN}✓ Deployment completed successfully${NC}"
echo "=========================================="

