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
