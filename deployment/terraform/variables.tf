variable "app_name" {
  type        = string
  description = "Name of the application"
  default     = "thoughts"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
  default     = "prod"
}

variable "aws_region" {
  type        = string
  description = "AWS region for deploying resources"
  default     = "us-east-1"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of an existing EC2 KeyPair to enable SSH access"
  default     = "your-key-pair-name"  # Replace with your actual key pair name
}

variable "github_token" {
  type        = string
  description = "GitHub token for accessing container registry"
  sensitive   = true
}
