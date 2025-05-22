# GitHub Workflows

This directory contains GitHub Actions workflows that automate the build, test, and deployment processes for the Thoughts application.

## Available Workflows

### 1. Backend Workflow (`.github/workflows/backend.yml`)

**Triggered on:**
- Push to `main` branch (changes in `backend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch

**Jobs:**
1. **Build and Test**
   - Sets up Go 1.20 environment
   - Installs dependencies using Go modules
   - Runs tests
   - Verifies the build

2. **Docker Image Build**
   - Sets up Docker Buildx for multi-architecture builds
   - Logs in to GitHub Container Registry (GHCR)
   - Builds and pushes Docker images for both `linux/amd64` and `linux/arm64`
   - Tags images with:
     - `latest` (only on main branch)
     - Commit SHA
     - Branch name (for PRs)
     - Version tags (for releases)

3. **Image Publishing**
   - Pushes images to GitHub Container Registry
   - Adds metadata labels for better traceability
   - Outputs image information after successful build

**Required Secrets:**
- `JWT_SECRET`: Secret key for JWT token generation

### 2. Frontend Workflow (`.github/workflows/frontend.yml`)

**Triggered on:**
- Push to `main` branch (changes in `frontend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch

**Jobs:**
1. **Build and Test**
   - Sets up Node.js environment
   - Installs dependencies using npm
   - Runs linting
   - Executes tests
   - Verifies the production build

### 3. Terraform CI (`.github/workflows/terraform-ci.yml`)

**Triggered on:**
- Push to `main` branch (changes in `deployment/` directory)
- Pull requests to `main` branch

**Jobs:**
1. **Terraform Validation**
   - Sets up Terraform
   - Initializes Terraform
   - Validates the configuration
   - Performs `terraform plan`

## Environment Variables

### Backend
- `JWT_SECRET`: Secret key for JWT authentication
- `ENVIRONMENT`: Deployment environment (staging/production)
- `PORT`: Port on which the backend server runs (default: 8080)

## How to Use

### Manual Deployment
1. Go to Actions
2. Select the desired workflow (e.g., "Backend")
3. Click "Run workflow"
4. Select the environment (staging/production)
5. Click "Run workflow"

### Viewing Container Images
Images are available at:
```
ghcr.io/mesbahtanvir/thoughts-backend:<tag>
```

### Pulling Images
```bash
docker pull ghcr.io/mesbahtanvir/thoughts-backend:latest
```

## Best Practices
1. Always use secrets for sensitive information
2. Keep workflow files in version control
3. Use environment-specific configurations
4. Monitor workflow runs in the Actions tab
5. Review workflow logs for any issues

## Troubleshooting
- **Permission denied errors**: Ensure the GitHub token has the necessary permissions
- **Build failures**: Check the logs for specific error messages
- **Image not found**: Verify the image tag and that the workflow completed successfully

For more information, see [GitHub Actions documentation](https://docs.github.com/en/actions).
