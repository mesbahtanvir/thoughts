# GitHub Actions CI/CD Workflows

This directory contains the GitHub Actions workflows that power the CI/CD pipeline for the Thoughts application. These workflows automate the build, test, and deployment processes.

## 📋 Available Workflows

### 1. Frontend Workflow ([.github/workflows/frontend.yml](.github/workflows/frontend.yml))

**Purpose**: Build, test, and deploy the React frontend application

**Trigger Events**:
- Push to `main` branch (changes in `frontend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch
- Scheduled (if configured)

**Jobs**:
1. **Build and Test**
   - Sets up Node.js environment
   - Installs dependencies using npm
   - Runs linting with ESLint
   - Executes tests with React Testing Library
   - Builds the production-ready React application
   - Uploads build artifacts

2. **Deploy to S3/CloudFront** (if enabled)
   - Configures AWS credentials
   - Syncs build artifacts to S3 bucket
   - Creates CloudFront invalidation
   - Sends deployment notifications

### 2. Backend Workflow ([.github/workflows/backend.yml](.github/workflows/backend.yml))

**Purpose**: Build, test, and deploy the Go backend service

**Trigger Events**:
- Push to `main` branch (changes in `backend/` directory)
- Pull requests to `main` branch
- Manual workflow dispatch
- Scheduled (if configured)

**Jobs**:
1. **Build and Test**
   - Sets up Go environment
   - Caches Go modules
   - Runs tests with coverage
   - Builds the Go binary
   - Runs security scans (if configured)

2. **Docker Image Build**
   - Builds multi-architecture Docker images
   - Pushes to GitHub Container Registry (GHCR)
   - Tags with:
     - `latest` (main branch only)
     - Commit SHA
     - Branch/Tag name

3. **Deploy to AWS** (if enabled)
   - Sets up AWS credentials
   - Deploys using AWS CDK/Terraform
   - Runs database migrations
   - Updates service configuration

## 🔑 Required Secrets

These secrets must be configured in your GitHub repository settings:

### Frontend
- `AWS_ACCESS_KEY_ID`: AWS access key for S3/CloudFront
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `AWS_REGION`: AWS region (e.g., `us-east-1`)
- `S3_BUCKET`: S3 bucket name for frontend assets
- `CLOUDFRONT_DISTRIBUTION_ID`: CloudFront distribution ID

### Backend
- `AWS_ACCESS_KEY_ID`: AWS access key for ECS/EKS/EC2
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `JWT_SECRET`: Secret key for JWT token generation
- `DB_CONNECTION_STRING`: Database connection string
- `ENVIRONMENT`: Deployment environment (e.g., `production`, `staging`)

## 🚀 Deployment

### Automated Deployment

1. **Prerequisites**
   - AWS account with appropriate permissions
   - Required secrets configured in GitHub
   - Infrastructure provisioned (via Terraform/CDK)

2. **Triggering Deployments**
   - **Production**: Push to `main` branch (auto-deploys to production)
   - **Staging**: Push to `staging` branch (if configured)
   - **Manual**: Use the "Run workflow" button in GitHub Actions

### Manual Deployment

```bash
# Example: Deploy backend to AWS ECS
aws ecs update-service \
  --cluster thoughts-cluster \
  --service backend-service \
  --force-new-deployment

# Example: Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

## 🛠️ Troubleshooting

### Common Issues

1. **Workflow Failing**
   - Check the "Actions" tab for detailed logs
   - Verify all required secrets are set
   - Ensure AWS permissions are correctly configured

2. **Deployment Issues**
   - Check CloudWatch logs for the deployed service
   - Verify network connectivity (security groups, VPC settings)
   - Confirm the container can access required resources

3. **Docker Build Failures**
   - Check Dockerfile for syntax errors
   - Verify base images exist and are accessible
   - Ensure build context is correct

## 🔒 Security

- **Secrets Management**: All sensitive data is stored in GitHub Secrets
- **Dependency Scanning**: Dependencies are regularly scanned for vulnerabilities
- **Code Scanning**: Static code analysis runs on every push
- **Branch Protection**: `main` branch is protected and requires PR reviews

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Deployment Best Practices](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/deployment-options.html)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Terraform Documentation](https://www.terraform.io/docs/index.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
