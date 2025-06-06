#!/bin/bash

# Nginx Auto-Deploy Pro
# Author: Andrusv
# Description: Automated Nginx installation and configuration for Ubuntu/Debian.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo).${NC}" >&2
    exit 1
fi

echo -e "${YELLOW}Updating package lists...${NC}"
apt-get update -qq

if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}Installing Nginx...${NC}"
    apt-get install -y -qq nginx
else
    echo -e "${GREEN}Nginx is already installed. Skipping installation.${NC}"
fi

echo -e "${YELLOW}Setting up permissions for /var/www/html...${NC}"
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo -e "${YELLOW}Configuring Nginx service...${NC}"
systemctl enable --now nginx > /dev/null 2>&1

echo -e "${YELLOW}Verifying monitoring system...${NC}"

MONITOR_SERVICE="/etc/systemd/system/nginx-monitor.service"

if [ ! -f "$MONITOR_SERVICE" ]; then
    echo -e "${YELLOW}Creating monitoring service...${NC}"
    cat > "$MONITOR_SERVICE" <<EOF
[Unit]
Description=Nginx Monitoring Service
After=nginx.service

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do \
  if ! systemctl is-active --quiet nginx; then \
    echo "\$(date) - Nginx down! Restarting..." >> /var/log/nginx-monitor.log; \
    systemctl restart nginx; \
  fi; \
  sleep 30; \
done'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    echo -e "${YELLOW}Reloading systemd...${NC}"
    if systemctl daemon-reload; then
        echo -e "${GREEN}Systemd was fully reloaded${NC}"
    else
        echo -e "${RED}Error when reloading systemd${NC}" >&2
        exit 1
    fi
else
    echo -e "${GREEN}Monitoring system already exists. It won't be modified.${NC}"
fi

if systemctl is-active --quiet nginx-monitor; then
    echo -e "${GREEN}Monitoring system is already active"
else
    echo -e "${YELLOW}Enabling monitoring system...${NC}"
    if systemctl enable --now nginx-monitor.service > /dev/null 2>&1; then
        echo -e "${GREEN}Monitoring system activated${NC}"
    else
        echo -e "${RED}Error when enabling monitoring system${NC}" >&2
        exit 1
    fi
fi

if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}Nginx is running successfully!${NC}"
else
    echo -e "${RED}Error: Nginx failed to start. Check 'systemctl status nginx'.${NC}" >&2
    exit 1
fi

echo -e "${YELLOW}Testing HTTP response...${NC}"
if curl -s localhost > /dev/null; then
    echo -e "${GREEN}Success: Nginx is serving content.${NC}"
else
    echo -e "${RED}Warning: Could not fetch HTTP response. Check Nginx logs.${NC}" >&2
fi

echo -e "${GREEN}\nDeployment completed! ✔${NC}"