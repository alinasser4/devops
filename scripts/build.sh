#!/bin/bash

# Build script for CI/CD pipeline
# This script starts the test cluster and prepares the environment

set -e

echo "=========================================="
echo "Starting CI/CD Build Process"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEPLOY_DIR="./deploy"
COMPOSE_FILE="docker-compose.test.yml"

# Detect docker compose command
if docker compose version &>/dev/null; then
    DOCKER_COMPOSE="docker compose"
elif docker-compose version &>/dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}✗ Neither 'docker compose' nor 'docker-compose' is available${NC}"
    exit 1
fi

# Create deploy directory if it doesn't exist
echo -e "${YELLOW}Creating deploy directory...${NC}"
mkdir -p "$DEPLOY_DIR"

# Clean up any existing containers
echo -e "${YELLOW}Cleaning up existing containers...${NC}"
$DOCKER_COMPOSE -f "$COMPOSE_FILE" down -v || true

# Start the test cluster
echo -e "${YELLOW}Starting test cluster with docker-compose...${NC}"
$DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d

# Wait for services to be healthy
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 10

# Check if containers are running
echo -e "${YELLOW}Checking container status...${NC}"
if $DOCKER_COMPOSE -f "$COMPOSE_FILE" ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Test cluster started successfully${NC}"
else
    echo -e "${RED}✗ Failed to start test cluster${NC}"
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" logs
    exit 1
fi

echo -e "${GREEN}Build process completed successfully${NC}"
echo "=========================================="
