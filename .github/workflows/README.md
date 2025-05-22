# GitHub Actions Workflows

This directory contains the GitHub Actions workflows that power the CI/CD pipeline for the Thoughts application. These workflows automate the build, test, and deployment processes.

## 🏗️ Workflow Structure

### 1. Backend Workflow ([backend.yml](backend.yml))

**Purpose**: Build, test, and deploy the Go backend service

**Trigger Events**:
- Push to `main` branch (changes in `backend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch
- Scheduled (if configured)

**Jobs**:
1. **Build and Test**
   - Sets up Go 1.20+ environment
   - Caches Go modules for faster builds
   - Runs unit and integration tests
   - Performs code coverage analysis
   - Runs security scans (if configured)
   - Verifies the build

2. **Docker Image Build**
   - Sets up Docker Buildx for multi-architecture builds
   - Logs in to GitHub Container Registry (GHCR)
   - Builds and pushes Docker images for multiple platforms:
     - `linux/amd64`
     - `linux/arm64`
   - Tags images with:
     - `latest` (only on main branch)
     - Commit SHA
     - Branch/Tag name (for PRs and releases)
     - Version tags (e.g., `v1.0.0`)
   - Adds metadata labels for better traceability:
     - Git commit SHA
     - Build timestamp
     - Build URL

3. **Deploy to AWS** (if enabled)
   - Sets up AWS credentials
   - Deploys using AWS CDK/Terraform
   - Runs database migrations
   - Updates service configuration
   - Verifies deployment health

**Required Secrets**:
- `AWS_ACCESS_KEY_ID`: AWS access key for deployment
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `JWT_SECRET`: Secret key for JWT token generation
- `DB_CONNECTION_STRING`: Database connection string
- `ENVIRONMENT`: Deployment environment (e.g., `production`, `staging`)

### 2. Frontend Workflow ([frontend.yml](frontend.yml))

**Purpose**: Build, test, and deploy the React frontend application

**Trigger Events**:
- Push to `main` branch (changes in `frontend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch
- Scheduled (if configured)

**Jobs**:
1. **Build and Test**
   - Sets up Node.js environment (LTS version)
   - Caches npm dependencies
   - Installs project dependencies
   - Runs ESLint for code quality
   - Executes tests with React Testing Library
   - Generates code coverage report
   - Builds production-ready React application
   - Uploads build artifacts for deployment
   - Verifies the production build
   - Uploads build artifacts for deployment

2. **Deploy to S3/CloudFront** (if enabled)
   - Configures AWS credentials
   - Syncs build artifacts to S3 bucket
   - Creates CloudFront invalidation
   - Sends deployment notifications
   - Verifies the deployment

### 3. Terraform CI Workflow ([terraform-ci.yml](terraform-ci.yml))

**Purpose**: Validate and plan Terraform infrastructure changes

**Trigger Events**:
- Push to `main` branch (changes in `deployment/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch

**Jobs**:
1. **Terraform Validation**
   - Sets up Terraform
   - Initializes backend and modules
   - Validates the configuration
   - Performs `terraform plan`
   - Outputs plan summary
   - Posts plan as a PR comment (for PRs)
   - Fails if plan contains destructive changes

2. **Security Scanning** (if enabled)
   - Runs `tfsec` for security best practices
   - Runs `checkov` for infrastructure security
   - Fails on critical security issues

**Required Secrets**:
- `AWS_ACCESS_KEY_ID`: AWS access key for Terraform
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `GITHUB_TOKEN`: GitHub token for PR comments (auto-provided)

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
