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
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.test.yml"
DEPLOY_DIR="./deploy"

# Stop and remove containers
echo -e "${YELLOW}Stopping and removing containers...${NC}"
docker compose -f "$COMPOSE_FILE" down -v

# Clean up deploy directory (optional)
# Uncomment the next line if you want to remove deploy directory after cleanup
# rm -rf "$DEPLOY_DIR"

echo -e "${GREEN}✓ Cleanup completed${NC}"
echo "=========================================="
