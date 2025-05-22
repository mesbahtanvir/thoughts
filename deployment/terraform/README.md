# Thoughts Application Infrastructure

This directory contains Terraform configurations for deploying the Thoughts application to AWS.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) 1.0.0 or later
2. AWS CLI configured with appropriate credentials
3. GitHub Personal Access Token with `read:packages` scope
4. EC2 Key Pair in the target AWS region

## Setup

1. Copy the example variables file and update it with your values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and update the following:
   - `ec2_key_name`: Your EC2 Key Pair name
   - `github_token`: Your GitHub Personal Access Token with `read:packages` scope
   - Adjust other variables as needed

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the execution plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. When prompted, review the plan and type `yes` to apply.

## Variables

### Required Variables
- `ec2_key_name`: Name of an existing EC2 KeyPair to enable SSH access
- `github_token`: GitHub token for accessing container registry (requires `read:packages` scope)

### Optional Variables
- `app_name`: Name of the application (default: "thoughts")
- `environment`: Deployment environment (default: "prod")
- `aws_region`: AWS region (default: "us-east-1")
- `instance_type`: EC2 instance type (default: "t3.micro")

## Outputs

After applying the configuration, Terraform will output the public IP address of the EC2 instance where the application is deployed.

## Cleanup

To destroy all resources created by Terraform:

```bash
terraform destroy
```

## Security Note

- The `terraform.tfvars` file may contain sensitive information. It is included in `.gitignore` by default.
- Never commit sensitive values to version control.
- Consider using AWS Secrets Manager or AWS Parameter Store for production deployments.
