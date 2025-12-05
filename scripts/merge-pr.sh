#!/bin/bash

# Auto-merge PR script
# This script merges a PR when tests pass
# Requires GitHub CLI or API token

set -e

echo "=========================================="
echo "Auto-merging Pull Request"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN}"
GITHUB_REPO="${GITHUB_REPO:-YOUR_USERNAME/YOUR_REPO}"
PR_NUMBER="${PR_NUMBER}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}✗ GITHUB_TOKEN environment variable not set${NC}"
    exit 1
fi

if [ -z "$PR_NUMBER" ]; then
    echo -e "${RED}✗ PR_NUMBER environment variable not set${NC}"
    exit 1
fi

# Merge PR using GitHub API
echo -e "${YELLOW}Merging PR #${PR_NUMBER}...${NC}"

RESPONSE=$(curl -s -X PUT \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}/merge" \
  -d '{
    "commit_title": "Merge PR #'${PR_NUMBER}' - Tests Passed",
    "commit_message": "Automatically merged after successful CI/CD pipeline tests",
    "merge_method": "merge"
  }')

# Check if merge was successful
if echo "$RESPONSE" | grep -q '"merged":true'; then
    echo -e "${GREEN}✓ PR #${PR_NUMBER} merged successfully${NC}"
    
    # Delete the branch (optional)
    BRANCH_NAME=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
      "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}" | \
      grep -o '"head":{"ref":"[^"]*' | cut -d'"' -f4)
    
    echo -e "${YELLOW}Deleting branch: ${BRANCH_NAME}...${NC}"
    curl -s -X DELETE \
      -H "Authorization: token ${GITHUB_TOKEN}" \
      "https://api.github.com/repos/${GITHUB_REPO}/git/refs/heads/${BRANCH_NAME}" || \
      echo -e "${YELLOW}Note: Could not delete branch (may be protected)${NC}"
    
    exit 0
else
    echo -e "${RED}✗ Failed to merge PR${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

