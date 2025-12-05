#!/bin/bash

# Docker Installation Script for Ubuntu
# Run this script to install Docker and Docker Compose

set -e

echo "=========================================="
echo "Docker Installation Script"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}Please do not run as root${NC}"
   exit 1
fi

echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt-get update

echo -e "${YELLOW}Installing prerequisites...${NC}"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo -e "${YELLOW}Adding Docker's official GPG key...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo -e "${YELLOW}Adding Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "${YELLOW}Installing Docker Engine...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo -e "${YELLOW}Adding user to docker group...${NC}"
sudo usermod -aG docker $USER

echo -e "${GREEN}Docker installation completed!${NC}"
echo -e "${YELLOW}Please log out and log back in for group changes to take effect.${NC}"
echo ""
echo "After logging back in, verify installation with:"
echo "  docker --version"
echo "  docker compose version"
echo "  docker run hello-world"

