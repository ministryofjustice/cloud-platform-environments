resource "aws_wafv2_ip_set" "frontend" {
  count = length(var.waf_allowed_ips) > 0 ? 1 : 0

  provider = aws.virginia

  name               = "${var.namespace}-frontend-allowed-ips"
  description        = "Allowed IPs for ${var.namespace} CloudFront distribution"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.waf_allowed_ips
}

resource "aws_wafv2_web_acl" "frontend" {
  provider = aws.virginia

  name  = "${var.namespace}-frontend-waf"
  scope = "CLOUDFRONT"

  # Shared response body for deliberate access-control blocks (IP allowlist,
  # geo restriction) below. These are given their own fixed 403 response so
  # the CloudFront distribution's 403 -> /index.html custom_error_response
  # (added to recover from expired-session/origin 403s) can never mask them:
  # a WAF rule's own custom_response always takes precedence over a
  # distribution's custom_error_response for the same status code.
  custom_response_body {
    key          = "access_denied"
    content      = "<html><body><h1>403 Forbidden</h1><p>Access to this resource is restricted.</p></body></html>"
    content_type = "TEXT_HTML"
  }

  default_action {
    dynamic "allow" {
      for_each = length(var.waf_allowed_ips) > 0 ? [] : [1]
      content {}
    }

    dynamic "block" {
      for_each = length(var.waf_allowed_ips) > 0 ? [1] : []
      content {
        custom_response {
          response_code            = 403
          custom_response_body_key = "access_denied"
        }
      }
    }
  }

  dynamic "rule" {
    for_each = length(var.waf_allowed_ips) > 0 ? [1] : []
    content {
      name     = "AllowListedIPs"
      priority = 1

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.frontend[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.namespace}-allowed-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  # Geo restriction, enforced here (with its own custom response) instead of
  # via the CloudFront distribution's native `restrictions.geo_restriction`,
  # which has no custom-response option and would otherwise be masked by the
  # distribution's 403 -> /index.html custom_error_response below.
  dynamic "rule" {
    for_each = var.geo_restriction_type != "none" ? [1] : []
    content {
      name     = "GeoRestriction"
      priority = 2

      action {
        block {
          custom_response {
            response_code            = 403
            custom_response_body_key = "access_denied"
          }
        }
      }

      statement {
        dynamic "not_statement" {
          for_each = var.geo_restriction_type == "whitelist" ? [1] : []
          content {
            statement {
              geo_match_statement {
                country_codes = var.geo_restriction_locations
              }
            }
          }
        }

        dynamic "geo_match_statement" {
          for_each = var.geo_restriction_type == "blacklist" ? [1] : []
          content {
            country_codes = var.geo_restriction_locations
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.namespace}-geo-restriction"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.namespace}-common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.namespace}-frontend-waf"
    sampled_requests_enabled   = true
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# WAF CloudWatch Logging
# Log group names must start with aws-waf-logs-
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "waf" {
  provider = aws.virginia

  name              = "aws-waf-logs-${var.namespace}-frontend"
  retention_in_days = var.waf_log_retention_days

  tags = merge(var.tags, {
    Name = "${var.namespace}-frontend-waf-logs"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "frontend" {
  provider = aws.virginia

  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.frontend.arn

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}
