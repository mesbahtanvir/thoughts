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

  # Pass the backend API URL to the frontend
  api_url = "http://${module.backend.instance_public_ip}" # Backend runs on port 80
}

# Backend module
module "backend" {
  source = "./modules/backend"

  environment  = var.environment
  github_token = var.github_token
  jwt_secret   = var.jwt_secret
}
