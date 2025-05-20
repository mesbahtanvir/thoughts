variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
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

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the frontend domain"
  type        = string
  default     = ""
}
