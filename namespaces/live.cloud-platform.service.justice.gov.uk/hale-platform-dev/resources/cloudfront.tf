locals {
  # Tags previously applied by the cloud-platform-terraform-cloudfront module.
  cloudfront_tags = {
    # Mandatory
    business-unit = var.business_unit
    application   = var.application
    is-production = var.is_production
    owner         = var.team_name
    namespace     = var.namespace
    service-area  = var.service_area

    # Optional
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
  }

  # Arbitrary, stable identifier shared by the origin and the origin access control.
  cloudfront_origin_id = random_id.cloudfront.hex
}

########################
# Generate identifiers #
########################

resource "random_id" "cloudfront" {
  byte_length = 8
}

##################################
# Create CloudFront distribution #
##################################

resource "aws_cloudfront_distribution" "cloudfront" {
  enabled         = true
  aliases         = [var.cloudfront_alias]
  comment         = "application: ${var.application}, environment: ${var.environment}"
  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_All"
  tags            = local.cloudfront_tags

  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = "${module.s3_bucket.bucket_name}.s3.eu-west-2.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront.id
    origin_id                = local.cloudfront_origin_id
  }

  # Serves everything that does not match an ordered_cache_behavior below -
  # principally /uploads/*. Deliberately NO CORS: nothing loads uploads
  # cross-origin, and wp-document-revisions stores access-controlled documents
  # under uploads/sites/ (see opt/php/wpdr-document-upload-dir.php in
  # hale-platform). CORS is scoped to /assets/* instead.
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    target_origin_id           = local.cloudfront_origin_id
    viewer_protocol_policy     = "redirect-to-https"                    # Enforce redirecting HTTP to HTTPS
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy
  }

  # Compiled theme assets, published per release by the hale-platform build.
  #
  # CORS is needed HERE AND ONLY HERE: @font-face and ES module scripts (the
  # Hale theme adds type="module" to govuk-frontend) are always fetched in
  # CORS mode, so without Access-Control-Allow-Origin the browser discards
  # them even though S3 returns 200.
  ordered_cache_behavior {
    path_pattern               = "/assets/*"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    target_origin_id           = local.cloudfront_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    response_headers_policy_id = "e61eb60c-9c35-4d20-a928-2b84e02af89c" # Managed-CORS-and-SecurityHeadersPolicy
  }

  # Per-site colour CSS is regenerated in place when an editor changes a
  # site's colours, so it must never be cached.
  ordered_cache_behavior {
    path_pattern               = "/uploads/sites/*/*colours*.css"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    target_origin_id           = local.cloudfront_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.cloudfront_alias_cert_validation.certificate_arn
    ssl_support_method             = "sni-only"
  }

  depends_on = [aws_acm_certificate_validation.cloudfront_alias_cert_validation]
}

################################
# Create Origin Access Control #
################################

resource "aws_cloudfront_origin_access_control" "cloudfront" {
  name                              = local.cloudfront_origin_id
  description                       = "application: ${var.application}, environment: ${var.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

###########################
# Create S3 bucket policy #
###########################

data "aws_iam_policy_document" "cloudfront_bucket_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${module.s3_bucket.bucket_name}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.cloudfront.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.cloudfront_bucket_policy.json
}

#########################################################################
# State migration from module "cloudfront_with_ordered"                 #
# These blocks re-parent the existing state entries onto the resources  #
# above so nothing is destroyed or recreated. They can be deleted once  #
# a plan has been applied on every environment using this code.         #
#########################################################################

moved {
  from = module.cloudfront_with_ordered.random_id.id
  to   = random_id.cloudfront
}

moved {
  from = module.cloudfront_with_ordered.aws_cloudfront_distribution.this
  to   = aws_cloudfront_distribution.cloudfront
}

moved {
  from = module.cloudfront_with_ordered.aws_cloudfront_origin_access_control.this
  to   = aws_cloudfront_origin_access_control.cloudfront
}

moved {
  from = module.cloudfront_with_ordered.aws_s3_bucket_policy.this
  to   = aws_s3_bucket_policy.cloudfront
}

resource "kubernetes_secret" "cloudfront_url" {
  metadata {
    name      = "cloudfront-output"
    namespace = var.namespace
  }

  data = {
    cloudfront_url   = aws_cloudfront_distribution.cloudfront.domain_name
    cloudfront_alias = var.cloudfront_alias
  }
}
