variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where resources will be created"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for the backend"
}

variable "key_name" {
  type        = string
  description = "Name of an existing EC2 KeyPair to enable SSH access"
}

variable "github_token" {
  type        = string
  description = "GitHub token for accessing container registry"
  sensitive   = true
}

variable "jwt_secret" {
  type        = string
  description = "JWT secret key for authentication"
  sensitive   = true
}

# Data source for the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
