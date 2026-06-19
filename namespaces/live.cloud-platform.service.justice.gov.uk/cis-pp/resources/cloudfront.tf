# -----------------------------------------------------------------------------
# CloudFront Origin Access Control (us-east-1)
# -----------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "frontend" {
  provider = aws.virginia

  name                              = "${var.environment}-frontend-oac"
  description                       = "Origin Access Control for ${var.environment} frontend S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------------------------------------------------------------
# CloudFront Distribution (global service, defined in us-east-1)
# -----------------------------------------------------------------------------
# checkov:skip=CKV2_AWS_42:Custom SSL certificate optional - using CloudFront default or provided ACM certificate
# checkov:skip=CKV2_AWS_32:Response headers policy not required - security headers handled via WAF
# checkov:skip=CKV2_AWS_47:WAF Log4j AMR configuration not required - WAF rules managed separately
resource "aws_cloudfront_distribution" "frontend" {
  #checkov:skip=CKV_AWS_310:Single S3 origin static frontend - origin failover not required
  #checkov:skip=CKV_AWS_374:Geo restriction not required - access controlled via WAF IP allowlist
  provider = aws.virginia

  enabled             = true
  comment             = "${var.environment} Frontend Distribution"
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class
  # web_acl_id          = aws_wafv2_web_acl.frontend.arn

  # Custom domain aliases - required for CloudFront to respond to custom domain
  aliases = var.use_custom_certificate ? [var.cloudfront_alias] : []

  # Access logging configuration (S3)
  # Logs include geo-location blocks and all request details
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_regional_domain_name
    prefix          = "cloudfront/"
  }

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "${var.environment}-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.environment}-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0 # Don't cache by default - let S3 metadata control caching
    max_ttl                = 86400
    compress               = true
  }

  # Cache behavior for static assets (/_next/static/) - long cache
  ordered_cache_behavior {
    path_pattern     = "/_next/static/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.environment}-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 31536000 # 1 year - static files are hashed
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  # Custom error responses for SPA routing
  # Returns index.html for 403/404 errors, allowing client-side routing to handle paths
  # Short cache to ensure route changes are picked up quickly
  # custom_error_response {
  #   error_code            = 403
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  #   error_caching_min_ttl = 0
  # }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.use_custom_certificate ? false : (var.acm_certificate_arn == "" ? true : false)
    acm_certificate_arn            = var.use_custom_certificate ? aws_acm_certificate.frontend[0].arn : (var.acm_certificate_arn != "" ? var.acm_certificate_arn : null)
    ssl_support_method             = var.use_custom_certificate || var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.use_custom_certificate || var.acm_certificate_arn != "" ? "TLSv1.2_2021" : null
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-frontend-distribution"
  })

  depends_on = [aws_acm_certificate_validation.frontend]
}

resource "kubernetes_secret" "cloudfront_output" {
  metadata {
    name      = "cloudfront-output"
    namespace = var.namespace
  }

  data = {
    cloudfront_alias           = var.cloudfront_alias
    cloudfront_url             = aws_cloudfront_distribution.frontend.domain_name
    cloudfront_distribution_id = aws_cloudfront_distribution.frontend.id
  }
}
