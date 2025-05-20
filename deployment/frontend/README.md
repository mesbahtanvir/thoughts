# Frontend AWS Deployment

## Setup Instructions

1. **Create S3 Bucket**:
   ```bash
   aws s3api create-bucket --bucket thoughts-frontend --region us-east-1
   ```

2. **Enable Static Website Hosting**:
   ```bash
   aws s3 website s3://thoughts-frontend/ --index-document index.html --error-document index.html
   ```

3. **Configure Bucket Policy** (update the bucket name):
   ```bash
   aws s3api put-bucket-policy --bucket thoughts-frontend --policy file://bucket-policy.json
   ```

4. **Create CloudFront Distribution**:
   - Use AWS Console or CLI with the provided configuration file
   - Note the CloudFront Distribution ID and domain name for GitHub Actions

5. **Update API_BASE_URL**:
   - Update the API endpoint in `src/services/api.js` to point to your Elastic Beanstalk environment

## Deployment

The GitHub Actions workflow will handle the build and deployment process:
1. Build the React application
2. Upload the build artifacts to S3
3. Create an invalidation in CloudFront to clear the cache

## Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`: AWS access key with permissions for S3 and CloudFront
- `AWS_SECRET_ACCESS_KEY`: Corresponding secret key
- `AWS_REGION`: AWS region (e.g., us-east-1)
- `AWS_S3_BUCKET`: S3 bucket name (e.g., thoughts-frontend)
- `AWS_CLOUDFRONT_DISTRIBUTION_ID`: CloudFront distribution ID
