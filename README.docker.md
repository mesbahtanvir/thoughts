# Docker Deployment for Thoughts Application

This guide explains how to deploy the Thoughts application using Docker Compose, which runs both the backend and frontend on the same machine.

## Backend Docker Setup

The backend is containerized using a multi-stage build process:
1. First stage builds the Go application
2. Second stage creates a minimal runtime environment
3. SQLite database is persisted using a Docker volume

### CI/CD Integration

The Docker setup is compatible with the GitHub Actions workflow in `.github/workflows/backend.yml`, which:
- Builds and tests the Go application
- Creates a multi-platform Docker image (linux/amd64, linux/arm64)
- Pushes the image to GitHub Container Registry
- Securely handles the JWT_SECRET through GitHub Secrets

## Prerequisites

- Docker and Docker Compose installed on your machine
- Git (to clone the repository)

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/thoughts.git
   cd thoughts
   ```

2. Create an environment file:
   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file and set a secure JWT secret:
   ```bash
   # Generate a secure key
   openssl rand -base64 32
   
   # Then update the JWT_SECRET value in .env
   ```

## Deployment

1. Build and start the containers:
   ```bash
   docker-compose up -d
   ```

2. Check the status of the containers:
   ```bash
   docker-compose ps
   ```

3. View logs:
   ```bash
   # All services
   docker-compose logs -f
   
   # Specific service
   docker-compose logs -f backend
   docker-compose logs -f frontend
   ```

## Accessing the Application

- Frontend: http://localhost
- Backend API: http://localhost:8080

## Security Considerations

- **JWT Secret**: The JWT secret is used for authentication. Make sure to change the default value in the `.env` file for production deployments. This is a critical security component.
- **HTTPS**: For production, consider adding HTTPS by using a reverse proxy like Nginx with Let's Encrypt certificates.

## Stopping the Application

```bash
docker-compose down
```

To remove all data volumes as well:
```bash
docker-compose down -v
```

## Updating the Application

1. Pull the latest changes:
   ```bash
   git pull
   ```

2. Rebuild and restart the containers:
   ```bash
   docker-compose up -d --build
   ```

## Troubleshooting

- If the frontend can't connect to the backend, check that the `HOST` environment variable is set correctly in the `.env` file.
- If you encounter permission issues with the data volume, check the ownership of the mounted directories.
- For any other issues, check the container logs using `docker-compose logs`.
