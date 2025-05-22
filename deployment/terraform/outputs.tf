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

output "frontend_configured_api_url" {
  description = "API URL that the frontend is configured to use"
  value       = module.frontend.api_url
}

# Backend outputs
output "backend_public_ip" {
  description = "Public IP address of the backend EC2 instance"
  value       = module.backend.instance_public_ip
}

output "backend_api_url" {
  description = "URL of the backend API"
  value       = "http://${module.backend.instance_public_ip}"
}
