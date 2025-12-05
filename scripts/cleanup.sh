#!/bin/bash

# Cleanup script
# This script stops and removes the test cluster

set -e

echo "=========================================="
echo "Cleaning up test environment"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.test.yml"
DEPLOY_DIR="./deploy"

# Detect docker compose command
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}✗ Neither 'docker compose' nor 'docker-compose' is available${NC}"
    exit 1
fi

# Stop and remove containers
echo -e "${YELLOW}Stopping and removing containers...${NC}"
$DOCKER_COMPOSE -f "$COMPOSE_FILE" down -v || true

# Clean up deploy directory (optional)
# Uncomment the next line if you want to remove deploy directory after cleanup
# rm -rf "$DEPLOY_DIR"

echo -e "${GREEN}✓ Cleanup completed${NC}"
echo "=========================================="
