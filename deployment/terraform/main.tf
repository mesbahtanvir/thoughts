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
}

# Backend module
module "backend" {
  source = "./modules/backend"


  app_name     = var.app_name
  environment  = var.environment
  vpc_id       = data.aws_vpc.default.id
  key_name     = var.ec2_key_name
  github_token = var.github_token
}
