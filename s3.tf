# --- 1. S3 BUCKET & SETTINGS ---
resource "aws_s3_bucket" "frontend" {
  bucket        = "univ-lab-frontend-orest-${random_id.id.hex}"
  force_destroy = true
}

resource "random_id" "id" {
  byte_length = 4
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
  error_document { key = "index.html" }
}

# --- 2. SECURITY (Відкриваємо доступ) ---
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.public_access, aws_s3_bucket_ownership_controls.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

# --- 3. CLOUDFRONT (CDN через Website Endpoint) ---
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    # Ключова зміна: використовуємо website_endpoint
    domain_name = aws_s3_bucket_website_configuration.hosting.website_endpoint
    origin_id   = "S3Website-${aws_s3_bucket.frontend.bucket}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Website-${aws_s3_bucket.frontend.bucket}"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# --- 4. UPLOAD (Завантаження файлів) ---
resource "aws_s3_object" "dist" {
  for_each = fileset("${path.module}/frontend/build", "**")

  bucket = aws_s3_bucket.frontend.id
  key    = each.value
  source = "${path.module}/frontend/build/${each.value}"
  content_type = lookup({
    "html" = "text/html",
    "js"   = "application/javascript",
    "css"  = "text/css",
    "svg"  = "image/svg+xml",
    "png"  = "image/png",
    "ico"  = "image/x-icon"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")

  etag = filemd5("${path.module}/frontend/build/${each.value}")
}

# --- 5. AUTOMATION (Скидання кешу) ---
resource "null_resource" "invalidate_cache" {
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.s3_distribution.id} --paths '/*'"
  }
  depends_on = [aws_s3_object.dist]
}

# --- 6. OUTPUTS ---
output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.hosting.website_endpoint}"
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
