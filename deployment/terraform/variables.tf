variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "thoughts"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "frontend_domain" {
  description = "Domain name for the frontend application"
  type        = string
  default     = ""
}

variable "api_domain" {
  description = "Domain name for the backend API"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the backend"
  type        = string
  default     = "t2.micro"
}

variable "db_enabled" {
  description = "Whether to deploy a database for the backend"
  type        = bool
  default     = false
}
