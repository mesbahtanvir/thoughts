variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
}

variable "aws_region" {
  type        = string
  description = "AWS region for deploying resources"
}

variable "api_url" {
  type        = string
  description = "The URL of the backend API that the frontend should use"
}

# Uncomment if you want to use a custom domain with SSL
# variable "domain_name" {
#   type        = string
#   description = "Domain name for the frontend"
#   default     = ""
# }

# variable "certificate_arn" {
#   type        = string
#   description = "ARN of the SSL certificate in ACM"
#   default     = ""
# }
