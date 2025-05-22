provider "aws" {
  region = var.aws_region
}

# Configure Terraform backend if needed
# terraform {
#   backend "s3" {
#     bucket  = "your-terraform-state-bucket"
#     key     = "thoughts/terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }
# }

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Frontend module
module "frontend" {
  source = "./modules/frontend"

  app_name    = var.app_name
  environment = var.environment
  aws_region  = var.aws_region
  
  # Note: The API URL is now set during the frontend build process
  # using environment variables or a build script
}

# Backend module
module "backend" {
  source = "./modules/backend"


  app_name     = var.app_name
  environment  = var.environment
  vpc_id       = data.aws_vpc.default.id
  ec2_key_name = var.ec2_key_name
  github_token = var.github_token
  jwt_secret   = var.jwt_secret
  allowed_ips  = var.allowed_ips
}
