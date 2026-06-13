# Production Deployment Guide

This guide describes how to deploy the Tolab University Backend using Docker, Nginx, PHP-FPM, Supervisor, Redis, and MySQL.

---

## 1. Prerequisites & Host Server Configuration

Your production server (e.g. AWS EC2, DigitalOcean Droplet, Ubuntu 22.04 LTS VPS) should have:
- **Docker Engine** (v24.0+)
- **Docker Compose** (v2.20+)
- **Git**
- A domain name mapped to the server IP (e.g. `api.tolab.edu`)

### Install Docker & Docker Compose (Ubuntu)
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Allow running docker without sudo
sudo usermod -aG docker $USER
newgrp docker
```

---

## 2. Setting Up the Application

1. **Clone the repository** to the deployment directory on your server:
   ```bash
   git clone <repository_url> /var/www/tolab-backend
   cd /var/www/tolab-backend
   ```

2. **Configure Environment Variables**:
   Create the production `.env` file from the checklist:
   ```bash
   cp .env.example .env
   nano .env
   ```
   *Modify all values as appropriate. Ensure `APP_ENV=production`, `APP_DEBUG=false`, `QUEUE_CONNECTION=redis`, and change all default database/redis/auth passwords.*

3. **Generate a Secure Application Key**:
   If not already configured, run a temporary docker container to generate the app key:
   ```bash
   docker run --rm -v $(pwd):/var/www/html php:8.4-cli-alpine sh -c "cd /var/www/html && php artisan key:generate --show"
   ```
   Paste the generated base64 string into the `APP_KEY` field in your `.env`.

---

## 3. Starting the Containers

Run the build and orchestrate all services in daemon mode:
```bash
docker compose up -d --build
```

### Verify Service Status
To check if all services are running and healthy:
```bash
docker compose ps
```

The services defined in `docker-compose.yml` are:
- **`app`**: Serving Nginx (port 80) and PHP-FPM (port 9000). Runs migrations and caching commands on startup.
- **`worker`**: Supervisord process manager running Horizon for queues.
- **`scheduler`**: A cron simulation loop invoking `php artisan schedule:run` every minute.
- **`redis`**: Key-value cache and queue storage.
- **`db`**: MySQL database container (used if external DB is not configured).

---

## 4. Configuring Let's Encrypt SSL / HTTPS

To secure production traffic (SSL termination), configure Nginx on the **host machine** to act as a reverse proxy forwarding HTTPS requests to the Docker container port (`8000` by default).

### Install Certbot and Host Nginx
```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

### Create Nginx Reverse Proxy Config
Create `/etc/nginx/sites-available/api.tolab.edu`:
```nginx
server {
    listen 80;
    server_name api.tolab.edu;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site and obtain the certificate:
```bash
sudo ln -s /etc/nginx/sites-available/api.tolab.edu /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Obtain SSL Certificate
sudo certbot --nginx -d api.tolab.edu
```

---

## 5. Monitoring & Maintenance

### Access Logs
View logs for all services or specific ones:
```bash
# All logs
docker compose logs -f

# Web app and PHP logs
docker compose logs -f app

# Horizon queue worker logs
docker compose logs -f worker
```

### Horizon Queue Dashboard
You can monitor job throughput, latency, and failed jobs by visiting the Horizon dashboard at:
`https://api.tolab.edu/horizon`

*Access is restricted to Admin users based on the gate rules defined in `HorizonServiceProvider.php`.*

### Database Backups (If using containerized DB)
Run a script or cron job on the host to back up the database:
```bash
docker exec tolab_db mysqldump -u <db_user> -p<db_password> <db_name> > /backups/db_backup_$(date +%F).sql
```

### Deploying Updates (Manually)
When pushing updates to production:
```bash
git pull origin main
docker compose up -d --build
```
*The entrypoint script will automatically run database migrations and rebuild the configuration caches.*
