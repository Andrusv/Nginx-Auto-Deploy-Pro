# Nginx Auto-Deploy Pro 🚀  

**Automated, production-ready Nginx server deployment with zero manual steps.**  

![Nginx Logo](https://nginx.org/nginx.png)

## 🔍 Overview  
A **Bash script** designed to automate the installation, configuration, and service management of Nginx on Ubuntu/Debian systems. Ideal for DevOps engineers who need reproducible, error-free server setups.  

### ⚙️ Features  
- **Silent installation** (non-interactive) of the latest Nginx version.  
- **Auto-configuration** of:  
  - File permissions (`/var/www/html`).  
  - Systemd service health checks.  
- **Idempotent** — can be safely rerun without side effects.  

## 🛠️ Technical Deep Dive  

### 📜 Script Logic  
1. **Dependency Checks**:  
   - Validates root permissions (`sudo`).  
   - Checks for existing Nginx installations to avoid conflicts.  

2. **Installation**:  
   - Uses `apt-get` (Debian/Ubuntu) with `-y` flag for unattended setup.  

3. **Post-Install Configuration**:  
   - Sets strict permissions (`chown -R www-data:www-data /var/www/html`).  
   - Ensures the Nginx systemd service is enabled and running:  
     ```bash
     systemctl enable --now nginx  
     ```  

4. **Validation**:  
   - Checks service status (`systemctl is-active nginx`).  
   - Optional: Tests HTTP response with `curl localhost`.  

## 🚀 Quick Start  

### Prerequisites  
- Ubuntu/Debian OS.  
- `sudo` privileges.  

### Usage  
```bash
git clone https://github.com/Andrusv/nginx-auto-deploy-pro.git  
cd nginx-auto-deploy-pro  
chmod +x deploy_nginx.sh  
sudo ./deploy_nginx.sh  
