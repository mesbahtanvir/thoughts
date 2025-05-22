variable "github_token" {
  type        = string
  description = "GitHub token for pulling the container image"
  sensitive   = true
}

variable "jwt_secret" {
  type        = string
  description = "JWT secret for the application"
  sensitive   = true
  default     = "your_secure_jwt_secret_here"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
  default     = "production"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
  default     = "ami-0c4f7023847b90238" # Ubuntu 20.04 LTS in us-east-1 (2023-03-23)
}

