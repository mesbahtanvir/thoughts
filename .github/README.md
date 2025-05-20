# GitHub Workflows for Thoughts Application

This directory contains the GitHub Actions workflows for continuous integration and delivery of the Thoughts application.

## Workflows

### Frontend Workflow (`frontend.yml`)

This workflow runs when changes are pushed to the `thoughts-frontend` directory:

- **Triggers**: Push or pull request to `main` branch affecting frontend code
- **CI Steps**:
  - Set up Node.js environment
  - Install dependencies
  - Run linting (non-blocking)
  - Run tests
  - Build the React application
  - Upload build artifacts

### Backend Workflow (`backend.yml`)

This workflow runs when changes are pushed to the `thoughts-backend` directory:

- **Triggers**: Push or pull request to `main` branch affecting backend code
- **CI Steps**:
  - Set up Go environment
  - Install dependencies
  - Run tests
  - Build the Go binary
  - Upload binary as artifact

## Deployment Instructions

The deployment jobs are currently commented out. To enable automated deployments:

1. Uncomment the `deploy` job sections in both workflow files
2. Add the following secrets in your GitHub repository settings:
   - `HOST`: Your server's hostname or IP address
   - `USERNAME`: SSH username for the server
   - `SSH_KEY`: Private SSH key for authentication

## Manual Setup for Production

For initial setup on your AWS server:

### Backend Setup
```bash
# Create systemd service
sudo nano /etc/systemd/system/thoughts-backend.service

# Add the following content:
[Unit]
Description=Thoughts Backend Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/thoughts-backend
ExecStart=/home/ubuntu/thoughts-backend/thoughts-backend
Restart=always
Environment=PORT=8080

[Install]
WantedBy=multi-user.target

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable thoughts-backend
sudo systemctl start thoughts-backend
```

### Frontend Setup with Nginx
```bash
# Install Nginx if not already installed
sudo apt update
sudo apt install -y nginx

# Configure Nginx site
sudo nano /etc/nginx/sites-available/ishkul.org

# Add the following content:
server {
    listen 80;
    server_name ishkul.org www.ishkul.org;
    
    root /var/www/html/ishkul.org;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:8080/api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# Enable the site
sudo ln -s /etc/nginx/sites-available/ishkul.org /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Set up SSL with Let's Encrypt
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d ishkul.org -d www.ishkul.org
```
