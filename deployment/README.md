# AWS Deployment for Thoughts App

This directory contains AWS deployment configuration for the Thoughts application using Terraform infrastructure as code.

## Architecture Overview

- **Frontend**: React app deployed to S3 + CloudFront
- **Backend**: Go server deployed to AWS Elastic Beanstalk

## Infrastructure as Code with Terraform

The deployment infrastructure is defined using Terraform with a modular structure:

```
terraform/
├── main.tf           # Main Terraform configuration
├── variables.tf      # Variable definitions
├── terraform.tfvars  # Configuration values (create from sample)
└── modules/
    ├── frontend/     # S3 + CloudFront configuration
    └── backend/      # Elastic Beanstalk configuration
```

## Required AWS Resources (Managed by Terraform)

1. **S3 Bucket**: For hosting the React frontend
2. **CloudFront Distribution**: CDN for frontend
3. **ECR Repository**: For backend Docker images
4. **Elastic Beanstalk Environment**: For the Go backend
5. **IAM Roles**: For service access permissions

## Prerequisites

1. **AWS Account**: You'll need an AWS account with appropriate permissions
2. **AWS CLI**: Configured with access keys
3. **Terraform**: Installed locally for development (CI/CD uses GitHub Actions)

## Initial Setup

1. **AWS Credentials**: Create an IAM user with programmatic access
   ```bash
   aws iam create-user --user-name thoughts-deployer
   aws iam attach-user-policy --user-name thoughts-deployer --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
   aws iam create-access-key --user-name thoughts-deployer
   ```

2. **Configure GitHub Secrets**: Add the following to your GitHub repository secrets
   - `AWS_ACCESS_KEY_ID`: The access key ID
   - `AWS_SECRET_ACCESS_KEY`: The secret access key
   - `AWS_REGION`: Your preferred AWS region (e.g., `us-east-1`)
   - `REACT_APP_API_URL`: Your backend API URL (after first deployment)

3. **Configure Terraform Variables**:
   ```bash
   cp terraform/terraform.tfvars.sample terraform/terraform.tfvars
   # Edit terraform.tfvars with your configuration
   ```

4. **Initialize Terraform** (for local development):
   ```bash
   cd terraform
   terraform init
   ```

5. **Run First Deployment**: Push to the main branch to trigger GitHub Actions workflows

## Manual Terraform Commands

```bash
# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure (use with caution)
terraform destroy
```

## Continuous Deployment

The GitHub Actions workflows automatically deploy:

1. **Frontend workflow**: Builds the React app and deploys to S3 + CloudFront
2. **Backend workflow**: Builds the Docker container and deploys to Elastic Beanstalk

## Connecting Frontend to Backend

After the first deployment:

1. Get the Elastic Beanstalk URL from the AWS Console or Terraform outputs
2. Add as a GitHub secret: `REACT_APP_API_URL=https://your-eb-url.elasticbeanstalk.com/api`
3. Redeploy the frontend for the changes to take effect

## Troubleshooting

- **Terraform state**: The state is stored locally by default. For production use, configure remote state in S3.
- **Deployment logs**: Check GitHub Actions logs for deployment issues
- **AWS resources**: Verify resource creation in the AWS Console
- **API connectivity**: Check the browser console for API connection issues
