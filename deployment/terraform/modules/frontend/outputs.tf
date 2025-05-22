# Output the website endpoint
output "website_endpoint" {
  description = "S3 website endpoint"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

# Output the CloudFront URL
output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"

  # This output depends on the CloudFront distribution being created
  depends_on = [aws_cloudfront_distribution.frontend]
}
