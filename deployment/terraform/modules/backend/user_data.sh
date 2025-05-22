#!/bin/bash
set -ex

# Update the system
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq

# Install required packages
DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip \
    awscli \
    nginx \
    jq

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -yq docker-ce docker-ce-cli containerd.io

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create application directory
mkdir -p /home/ubuntu/app
chown -R ubuntu:ubuntu /home/ubuntu/app

# Create Docker Compose file
cat > /home/ubuntu/app/docker-compose.yml << EOL
version: '3.8'

services:
  backend:
    image: ghcr.io/mesbahtanvir/thoughts-backend:latest
    container_name: thoughts-backend
    restart: always
    ports:
      - "8000:8080"
    environment:
      - JWT_SECRET=$${jwt_secret}
      - ENVIRONMENT=$${environment}
      - PORT=8080
    volumes:
      - app_data:/app/data
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  app_data:
EOL

# Create environment file
cat > /home/ubuntu/app/.env << EOL
JWT_SECRET=your_jwt_secret_here
ENVIRONMENT=production
EOL

# Create startup script
cat > /home/ubuntu/app/start.sh << 'EOL'
#!/bin/bash
set -e

# Source environment variables if they exist
if [ -f /home/ubuntu/app/.env ]; then
    set -a
    source /home/ubuntu/app/.env
    set +a
fi

# Login to GitHub Container Registry
echo "Logging in to GitHub Container Registry..."
if [ -n "\$GITHUB_TOKEN" ]; then
    echo "\$GITHUB_TOKEN" | docker login ghcr.io -u \${GITHUB_USERNAME} --password-stdin
else
    echo "WARNING: GITHUB_TOKEN not set, skipping container registry login"
fi

# Pull the latest image
echo "Pulling the latest image..."
docker-compose pull

# Start the container
echo "Starting the container..."
docker-compose up -d
EOL

chmod +x /home/ubuntu/app/start.sh
chown -R ubuntu:ubuntu /home/ubuntu/app

# Create a systemd service for the application
cat > /etc/systemd/system/$${app_name}.service << 'SERVICE_EOF'
[Unit]
Description=$${app_name} Backend Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/app
EnvironmentFile=/home/ubuntu/app/.env
Environment=GITHUB_USERNAME=mesbahtanvir
Environment=GITHUB_TOKEN=$${github_token}
ExecStart=/home/ubuntu/app/start.sh
ExecStop=/usr/bin/docker-compose down
Restart=on-failure
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Configure Nginx as a reverse proxy
cat > /etc/nginx/sites-available/default << 'EOL'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOL

# Enable and start services
systemctl enable docker
systemctl start docker
systemctl enable nginx
systemctl restart nginx
systemctl enable $${app_name}.service

# Reboot to apply all updates
reboot
