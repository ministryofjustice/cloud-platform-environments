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

  default_action {
    dynamic "allow" {
      for_each = length(var.waf_allowed_ips) > 0 ? [] : [1]
      content {}
    }

    dynamic "block" {
      for_each = length(var.waf_allowed_ips) > 0 ? [1] : []
      content {}
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

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = length(var.waf_allowed_ips) > 0 ? 2 : 1

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
}
