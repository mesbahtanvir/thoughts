output "s3_bucket_name" {
  description = "Name of the S3 bucket for the frontend"
  value       = aws_s3_bucket.frontend.id
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = try(aws_cloudfront_distribution.frontend[0].id, "")
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = try(aws_cloudfront_distribution.frontend[0].domain_name, "")
}

output "website_endpoint" {
  description = "S3 website endpoint"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${try(aws_cloudfront_distribution.frontend[0].domain_name, "")}"
}
