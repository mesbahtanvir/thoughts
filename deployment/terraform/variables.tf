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
  default     = "thoughts"
}

variable "github_token" {
  type        = string
  description = "GitHub token for accessing container registry"
  sensitive   = true
}

variable "github_username" {
  type        = string
  description = "GitHub username for container registry access"
  default     = "mesbahtanvir"
}

variable "jwt_secret" {
  type        = string
  description = "JWT secret key for authentication"
  sensitive   = true
  default     = "default-insecure-secret-change-me" # In production, always set this explicitly
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed IP addresses in CIDR notation (e.g., [\"123.45.67.89/32\"])"
  default     = []

  validation {
    condition     = alltrue([for ip in var.allowed_ips : can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}(/[0-9]{1,2})?$", ip))])
    error_message = "Each IP must be a valid IPv4 CIDR block (e.g., 192.168.1.1/32)."
  }
}


