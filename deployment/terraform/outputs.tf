# Frontend outputs
output "frontend_s3_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend"
  value       = module.frontend.s3_bucket_name
}

output "frontend_cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.frontend.cloudfront_distribution_id
}

output "frontend_url" {
  description = "URL of the deployed frontend application"
  value       = "https://${module.frontend.cloudfront_domain_name}"
}

# Backend outputs
output "backend_public_ip" {
  description = "Public IP address of the backend EC2 instance"
  value       = module.backend.public_ip
}

output "backend_public_dns" {
  description = "Public DNS of the backend EC2 instance"
  value       = module.backend.public_dns
}

output "backend_security_group_id" {
  description = "ID of the security group for the backend"
  value       = module.backend.security_group_id
}

output "backend_api_url" {
  description = "URL of the backend API"
  value       = "http://${module.backend.public_dns}/api"
}
