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

variable "ec2_key_name" {
  type        = string
  description = "Name of an existing EC2 KeyPair to enable SSH access"
}

variable "github_token" {
  type        = string
  description = "GitHub token for accessing private container registry"
  sensitive   = true
}

variable "allowed_ips" {
  description = "List of allowed IP addresses in CIDR notation (e.g., [\"123.45.67.89/32\"])"
  type        = list(string)
  default     = []
  validation {
    # Simple validation that checks for a basic IP/CIDR pattern
    # This is less strict but avoids complex regex escaping issues
    condition     = alltrue([for ip in var.allowed_ips : can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}(/[0-9]{1,2})?$", ip))])
    error_message = "Each IP must be a valid IPv4 CIDR block (e.g., 192.168.1.1/32)."
  }
}

variable "jwt_secret" {
  type        = string
  description = "JWT secret key for authentication"
  sensitive   = true
}

variable "github_username" {
  type        = string
  description = "GitHub username for container registry authentication"
  default     = "mesbahtanvir" # Default to your username, can be overridden
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
