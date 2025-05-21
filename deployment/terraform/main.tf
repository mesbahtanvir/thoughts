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

# Frontend module
module "frontend" {
  source = "./modules/frontend"

  app_name    = var.app_name
  environment = var.environment
  aws_region  = var.aws_region
}
