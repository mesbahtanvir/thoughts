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
