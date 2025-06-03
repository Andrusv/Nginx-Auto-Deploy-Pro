#!/bin/bash

# Nginx Auto-Deploy Pro
# Author: Andrusv
# Description: Automated Nginx installation and configuration for Ubuntu/Debian.

set -e  # Exit script on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo).${NC}" >&2
    exit 1
fi

# Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
apt-get update -qq

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}Installing Nginx...${NC}"
    apt-get install -y -qq nginx
else
    echo -e "${GREEN}Nginx is already installed. Skipping installation.${NC}"
fi

# Configure permissions for /var/www/html
echo -e "${YELLOW}Setting up permissions for /var/www/html...${NC}"
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Ensure Nginx service is enabled and running
echo -e "${YELLOW}Enabling and starting Nginx service...${NC}"
systemctl enable --now nginx > /dev/null 2>&1

# Verify Nginx is running
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}Nginx is running successfully!${NC}"
else
    echo -e "${RED}Error: Nginx failed to start. Check 'systemctl status nginx'.${NC}" >&2
    exit 1
fi

# Test HTTP response
echo -e "${YELLOW}Testing HTTP response...${NC}"
if curl -s localhost > /dev/null; then
    echo -e "${GREEN}Success: Nginx is serving content.${NC}"
else
    echo -e "${RED}Warning: Could not fetch HTTP response. Check Nginx logs.${NC}" >&2
fi

echo -e "${GREEN}\nDeployment completed! ✔${NC}"