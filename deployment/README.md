# Thoughts Application Deployment

This directory contains Terraform configurations for deploying the Thoughts application to AWS.

## Architecture

- **Frontend**: React application deployed to S3 with CloudFront distribution for caching and HTTPS
- **Backend**: (Not currently configured - previously deployed to AWS Elastic Beanstalk via Docker)

## Current Deployment Status

- **Frontend URL**: https://d27gaeqjiw3uw0.cloudfront.net
- **S3 Bucket**: thoughts-prod-frontend
- **CloudFront Distribution ID**: E3E2N09OEQKCJI

## Security

### Environment Variables

The following sensitive values are managed as Terraform variables and should be set in your environment or CI/CD pipeline:

- `JWT_SECRET`: Used for signing JWT tokens
  - Generate a strong secret: `openssl rand -base64 32`
  - Marked as sensitive in Terraform
  - Never commit to version control

- `GITHUB_TOKEN`: Personal access token for pulling container images from GitHub Container Registry
  - Must have `read:packages` scope
  - Managed as a sensitive variable in Terraform

### Secrets Management

1. **Local Development**:
   - Use a `.env` file (not committed to version control)
   - Add `.env` to `.gitignore`

2. **CI/CD**:
   - Store secrets in GitHub Secrets
   - Pass them to Terraform using environment variables

3. **Production**:
   - Use AWS Secrets Manager or Parameter Store
   - Rotate secrets regularly
   - Follow principle of least privilege

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v1.0.0+ installed
- Node.js and npm for building the frontend

## Project Structure

```
deployment/
├── terraform/
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output definitions
│   └── modules/
│       └── frontend/
│           ├── main.tf       # S3 and CloudFront configuration
│           ├── variables.tf   # Module variables
│           └── upload.tf     # S3 file upload configuration
└── README.md                 # This file
```

## Deployment Steps

### Frontend Deployment

1. Build the frontend:
   ```bash
   cd frontend
   npm run build
   ```

2. Navigate to the terraform directory:
   ```bash
   cd deployment/terraform
   ```

3. Initialize Terraform (first time only):
   ```bash
   terraform init
   ```

4. Deploy the infrastructure and upload the frontend files (all in one step):
   ```bash
   terraform apply -auto-approve
   ```

5. Get the CloudFront URL for your deployed frontend:
   ```bash
   terraform output frontend_url
   ```

## Key Features

### Automatic File Upload

The deployment automatically uploads the frontend build files to S3 using Terraform's `aws_s3_object` resource. This means:

- No separate AWS CLI commands needed for file upload
- Files are tracked in Terraform state
- Only changed files are uploaded (tracked by ETags)
- Proper content types are set automatically

### CloudFront Configuration

- Global CDN distribution for low-latency access worldwide
- HTTPS enabled by default with CloudFront's domain
- Proper cache settings for static assets
- Client-side routing support (SPA configuration)

### Security Features

- S3 bucket is completely private - no public access
- CloudFront Origin Access Control (OAC) for secure S3 access
- Restricted bucket policies

## Managing the Deployment

### Updating the Frontend

To update the frontend, build the React application and sync the new files to S3:

```
cd frontend
npm run build
cd ../deployment/terraform
S3_BUCKET=$(terraform output -raw module.frontend.s3_bucket_name)
aws s3 sync ../../frontend/build/ s3://$S3_BUCKET/ --delete

# Optionally, invalidate the CloudFront cache
CF_DIST_ID=$(terraform output -raw module.frontend.cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $CF_DIST_ID --paths "/*"
```

### Cleanup

To destroy all resources:

```
terraform destroy -target=module.frontend
```
