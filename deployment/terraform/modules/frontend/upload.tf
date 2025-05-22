# Upload all files from the build directory to the S3 bucket
locals {
  # Path to the frontend build directory
  build_dir = "${path.root}/../../frontend/build"
  
  # Path to the templates directory
  templates_dir = "${path.module}/templates"

  # Get all files from the build directory recursively
  files = fileset(local.build_dir, "**")

  # Map of content types for different file extensions
  mime_types = {
    "css"   = "text/css"
    "html"  = "text/html"
    "js"    = "application/javascript"
    "json"  = "application/json"
    "map"   = "application/json"
    "svg"   = "image/svg+xml"
    "png"   = "image/png"
    "jpg"   = "image/jpeg"
    "jpeg"  = "image/jpeg"
    "ico"   = "image/x-icon"
    "txt"   = "text/plain"
    "ttf"   = "font/ttf"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "env"   = "text/plain"
  }
  
  # Generate .env file content
  env_content = templatefile("${local.templates_dir}/env.tpl", {
    api_url = var.api_url
  })
}

# Upload each file to S3 with the appropriate content type
resource "aws_s3_object" "frontend_files" {
  for_each = local.files

  bucket = aws_s3_bucket.frontend.id
  key    = each.value
  source = "${local.build_dir}/${each.value}"

  # Determine the content type based on the file extension
  content_type = lookup(
    local.mime_types,
    length(regexall("\\.", each.value)) > 0 ? reverse(split(".", each.value))[0] : "",
    "application/octet-stream" # Default content type if extension is not recognized
  )

  # Calculate ETag to detect changes in source files
  etag = filemd5("${local.build_dir}/${each.value}")
}

# Upload the .env file with the API URL
resource "aws_s3_object" "env_file" {
  bucket  = aws_s3_bucket.frontend.id
  key     = ".env"
  content = local.env_content
  content_type = "text/plain"
  etag   = md5(local.env_content)
}
