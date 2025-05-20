variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
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

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the backend domain"
  type        = string
  default     = ""
}

variable "db_enabled" {
  description = "Whether to deploy a database for the backend"
  type        = bool
  default     = false
}
