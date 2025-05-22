# GitHub Actions Workflows

This directory contains the GitHub Actions workflows that automate the build, test, and deployment processes for the Thoughts application.

## 🏗️ Workflow Structure

### 1. Backend Workflow ([backend.yml](backend.yml))

**Purpose**: Build, test, and package the Go backend service

**Trigger Events**:
- Push to `main` branch (changes in `backend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch

**Jobs**:
1. **Build and Test**
   - Sets up Go 1.20 environment
   - Caches Go modules for faster builds
   - Installs dependencies
   - Runs tests with `go test`
   - Verifies the build

2. **Docker Image Build**
   - Sets up Docker Buildx for multi-architecture builds
   - Logs in to GitHub Container Registry (GHCR)
   - Builds and pushes Docker images for:
     - `linux/amd64`
     - `linux/arm64`
   - Tags images with:
     - `latest` (only on main branch)
     - Commit SHA
     - Branch name (for PRs)
     - Version tags (for releases)
   - Adds metadata labels for traceability

**Notes**:
- The backend is deployed to an EC2 instance configured via Terraform
- The EC2 instance is configured to pull the latest image on startup

**Required Secrets**:
- `AWS_ACCESS_KEY_ID`: AWS access key for deployment
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `JWT_SECRET`: Secret key for JWT token generation
- `DB_CONNECTION_STRING`: Database connection string
- `ENVIRONMENT`: Deployment environment (e.g., `production`, `staging`)

### 2. Frontend Workflow ([frontend.yml](frontend.yml))

**Purpose**: Build and test the React frontend application

**Trigger Events**:
- Push to `main` branch (changes in `frontend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch

**Jobs**:
1. **Build and Test**
   - Sets up Node.js 18 environment
   - Caches npm dependencies
   - Installs project dependencies
   - Runs ESLint for code quality (non-blocking)
   - Executes tests with React Testing Library
   - Builds production-ready React application
   - Verifies the production build

**Notes**:
- The frontend is built and tested but not automatically deployed
- Deployment to S3/CloudFront is a manual process (see main README)

## 🔧 Configuration

### Environment Variables

#### Backend
- `JWT_SECRET`: Secret key for JWT authentication (required for production)
- `PORT`: Port to run the server on (default: 8080)
- `ENVIRONMENT`: Deployment environment (e.g., `development`, `production`)

#### Frontend
- `REACT_APP_API_URL`: Base URL for the backend API (default: http://localhost:8080/api)

## 🚀 Deployment Guide

### Backend Deployment

1. **Build and Push Image** (automated on push to main)
   - The backend workflow builds and pushes a Docker image to GitHub Container Registry
   - The image is tagged with the commit SHA and branch name

2. **Update EC2 Instance**
   ```bash
   # SSH into the EC2 instance
   ssh -i your-key.pem ubuntu@your-ec2-ip
   
   # Pull the latest image
   docker pull ghcr.io/mesbahtanvir/thoughts-backend:latest
   
   # Restart the service
   sudo systemctl restart thoughts-backend
   ```

### Frontend Deployment

1. **Build the Application**
   ```bash
   cd frontend
   npm install
   npm run build
   ```

2. **Deploy to S3**
   ```bash
   # Sync build directory with S3 bucket
   aws s3 sync build/ s3://your-frontend-bucket --delete
   
   # Invalidate CloudFront cache (if using CloudFront)
   aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
   ```

## 🔒 Security Best Practices

1. **Secrets Management**
   - Store all sensitive data in GitHub Secrets
   - Never hardcode credentials in workflow files
   - Use environment-specific secrets when possible

2. **Workflow Security**
   - Enable branch protection for main branch
   - Require pull request reviews
   - Require status checks to pass before merging

3. **Infrastructure Security**
   - Use least-privilege IAM roles
   - Enable encryption at rest and in transit
   - Regularly rotate credentials and secrets

## 🛠️ Troubleshooting

### Common Issues

1. **Workflow Failing**
   - Check the "Actions" tab for detailed logs
   - Verify all required secrets are set
   - Ensure AWS permissions are correctly configured

2. **Deployment Issues**
   - Check EC2 instance logs: `journalctl -u thoughts-backend -f`
   - Verify network connectivity (security groups, VPC settings)
   - Confirm the container can access required resources

3. **Terraform Issues**
   - Run `terraform validate` locally
   - Check for state locking issues
   - Verify AWS credentials and permissions

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [AWS CLI Documentation](https://aws.amazon.com/cli/)

## 🔧 Configuration

### Environment Variables

#### Backend
- `JWT_SECRET`: Secret key for JWT authentication
- `ENVIRONMENT`: Deployment environment (e.g., `staging`, `production`)
- `PORT`: Port on which the backend server runs (default: `8080`)
- `DB_CONNECTION_STRING`: Database connection string
- `AWS_REGION`: AWS region for deployments (default: `us-east-1`)

#### Frontend
- `REACT_APP_API_URL`: Base URL for the backend API
- `REACT_APP_ENV`: Environment name (e.g., `development`, `production`)
- `REACT_APP_GA_TRACKING_ID`: Google Analytics tracking ID (optional)

## 🚀 Deployment Guide

### Manual Deployment

1. **Via GitHub UI**
   1. Go to "Actions" tab in the repository
   2. Select the desired workflow (e.g., "Backend" or "Frontend")
   3. Click "Run workflow"
   4. Select the target environment (staging/production)
   5. Optionally specify a specific branch or tag
   6. Click "Run workflow"

2. **Via GitHub CLI**
   ```bash
   # Trigger backend deployment
   gh workflow run backend.yml -f environment=production
   
   # Trigger frontend deployment
   gh workflow run frontend.yml -f environment=production
   ```

### Viewing Container Images

All container images are stored in GitHub Container Registry (GHCR):

- **Backend**: 
  ```
  ghcr.io/mesbahtanvir/thoughts-backend:<tag>
  ```
  
- **Frontend**:
  ```
  ghcr.io/mesbahtanvir/thoughts-frontend:<tag>
  ```

### Pulling Images

```bash
# Pull latest production backend image
docker pull ghcr.io/mesbahtanvir/thoughts-backend:latest

# Pull specific version
docker pull ghcr.io/mesbahtanvir/thoughts-backend:v1.0.0

# Pull by commit SHA
docker pull ghcr.io/mesbahtanvir/thoughts-backend:abc1234
```

## 🔒 Security Best Practices

1. **Secrets Management**
   - Store all sensitive data in GitHub Secrets
   - Never hardcode credentials in workflow files
   - Use environment-specific secrets when possible

2. **Workflow Security**
   - Enable branch protection for main branch
   - Require pull request reviews
   - Require status checks to pass before merging
   - Limit environment deployments to protected branches

3. **Infrastructure Security**
   - Use least-privilege IAM roles
   - Enable encryption at rest and in transit
   - Regularly rotate credentials and secrets
   - Enable security scanning in CI/CD pipeline

4. **Container Security**
   - Use minimal base images
   - Regularly update dependencies
   - Scan images for vulnerabilities
   - Sign and verify container images

## 🛠️ Troubleshooting

### Common Issues

1. **Workflow Failing**
   - Check the "Actions" tab for detailed logs
   - Verify all required secrets are set
   - Ensure AWS permissions are correctly configured
   - Check for rate limiting (especially with container registry)

2. **Deployment Issues**
   - Check CloudWatch logs for the deployed service
   - Verify network connectivity (security groups, VPC settings)
   - Confirm the container can access required resources
   - Check for environment variable mismatches

3. **Terraform Issues**
   - Run `terraform validate` locally
   - Check for state locking issues
   - Verify AWS credentials and permissions
   - Check for resource conflicts

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
