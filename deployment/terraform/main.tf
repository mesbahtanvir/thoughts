terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Uncomment this block to use S3 as a backend for terraform state
  # backend "s3" {
  #   bucket  = "thoughts-terraform-state"
  #   key     = "terraform.tfstate"
  #   region  = "us-east-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.aws_region
}

module "frontend" {
  source = "./modules/frontend"
  
  app_name        = var.app_name
  environment     = var.environment
  frontend_domain = var.frontend_domain
  api_domain      = var.api_domain
}

module "backend" {
  source = "./modules/backend"
  
  app_name      = var.app_name
  environment   = var.environment
  api_domain    = var.api_domain
  instance_type = var.instance_type
  db_enabled    = var.db_enabled
}
