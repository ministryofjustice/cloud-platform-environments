module "bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

# module "cloudfront" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=1.6.0"
#
#   bucket_id          = module.bucket.bucket_name
#   bucket_domain_name = module.bucket.bucket_domain_name
#
#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name
#   namespace              = var.namespace
#   environment_name       = var.environment_name
#   infrastructure_support = var.infrastructure_support
#   service_area           = var.service_area
# }

locals {
  export_bucket_cloudfront_target_origin_id = random_id.export_bucket_cloudfront_id.hex
}

resource "random_id" "export_bucket_cloudfront_id" {
  byte_length = 8
}

resource "aws_cloudfront_distribution" "export_bucket" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "application: ${var.application}, environment: ${var.environment_name}"
  http_version    = "http2and3"

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    target_origin_id           = local.export_bucket_cloudfront_target_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.auth.arn
    }
  }

  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = module.bucket.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.export_bucket.id
    origin_id                = local.export_bucket_cloudfront_target_origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_control" "export_bucket" {
  name                              = local.export_bucket_cloudfront_target_origin_id
  description                       = "application: ${var.application}, environment: ${var.environment_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "export_bucket_cloudfront_bucket_policy" {
  version = "2012-10-17"
  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${module.bucket.bucket_name}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.export_bucket.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "export_bucket_cloudfront" {
  bucket = module.bucket.bucket_name
  policy = data.aws_iam_policy_document.export_bucket_cloudfront_bucket_policy.json
}

resource "random_password" "username" {
  length  = 32
  special = false
}

resource "random_password" "password" {
  length  = 32
  special = false
}

resource "aws_cloudfront_function" "auth" {
  name    = "${var.namespace}-export-cloudfront-function"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-EOT
    function handler(event) {
      const request = event.request;
      const headers = request.headers;
      const expectedAuth = "Basic ${base64encode("${random_password.username.result}:${random_password.password.result}")}";

      if (!headers.authorization || headers.authorization.value !== expectedAuth) {
        return {
          statusCode: 401,
          statusDescription: "Unauthorized",
          headers: {
            "www-authenticate": {
              value: "Basic"
            }
          }
        };
      }

      return request;
    }
  EOT
}

resource "kubernetes_secret" "export_bucket" {
  metadata {
    name      = "export-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_name     = module.bucket.bucket_name
    bucket_arn      = module.bucket.bucket_arn
    irsa_policy_arn = module.bucket.irsa_policy_arn
    cloudfront_url  = aws_cloudfront_distribution.export_bucket.domain_name
    username        = random_password.username.result
    password        = random_password.password.result
  }
}
