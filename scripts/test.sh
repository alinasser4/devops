#!/bin/bash

# Test script
# This script runs the unit tests

set -e

echo "=========================================="
echo "Starting Test Execution"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.test.yml"
API_URL="http://php-apache/api.php"

# Run tests using Node.js container
echo -e "${YELLOW}Running API tests...${NC}"
docker-compose -f "$COMPOSE_FILE" exec -T nodejs sh -c "cd /app && API_URL=$API_URL node test-api.js"

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    echo "=========================================="
    exit 0
else
    echo -e "${RED}✗ Tests failed${NC}"
    echo "=========================================="
    exit 1
fi

