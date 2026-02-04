# Use existing internal ingress controller NLB (managed by Cloud Platform)
data "aws_lb" "ingress_internal_non_prod_nlb" {
  tags = {
    "kubernetes.io/service-name" = "ingress-controllers/nginx-ingress-internal-non-prod-controller"
  }
}

# Get the Kubernetes service to extract the internal NLB IP addresses that
# VPC Link connects to
# These IPs should be added to the ingress allowlist to allow API Gateway traffic
data "kubernetes_service" "ingress_internal_non_prod_controller" {
  metadata {
    name      = "nginx-ingress-internal-non-prod-controller"
    namespace = "ingress-controllers"
  }
}

# VPC Link for API Gateway
resource "aws_api_gateway_vpc_link" "api_gateway_vpc_link" {
  name        = "${var.namespace}-vpc-link"
  description = "VPC Link for ${var.namespace} API Gateway to internal NLB"
  target_arns = [data.aws_lb.ingress_internal_non_prod_nlb.arn]

  tags = local.default_tags
}
#===============================================================================
# API Gateway for Launchpad Auth API
#===============================================================================
resource "aws_api_gateway_rest_api" "api_gateway_lp_auth" {
  name                          = var.namespace
  disable_execute_api_endpoint  = false
  api_key_source                = "HEADER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = local.default_tags
}

# /v1 resource
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_lp_auth.root_resource_id
  path_part   = "v1"
}

# /v1/oauth2 resource
resource "aws_api_gateway_resource" "oauth2" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "oauth2"
}

resource "aws_api_gateway_resource" "oauth2_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  parent_id   = aws_api_gateway_resource.oauth2.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "oauth2_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  resource_id      = aws_api_gateway_resource.oauth2_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "oauth2_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  resource_id             = aws_api_gateway_resource.oauth2_proxy.id
  http_method             = aws_api_gateway_method.oauth2_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "${var.cloud_platform_launchpad_auth_api_url}/v1/oauth2/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.api_gateway_vpc_link.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# API Keys
resource "aws_api_gateway_api_key" "clients" {
  for_each = toset(local.api_clients)
  name     = each.key
  tags = local.default_tags
}

# Usage Plan
resource "aws_api_gateway_usage_plan" "default" {
  name = "${var.namespace}-external-apps"
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  tags = local.default_tags
}

# Associate API Keys with Usage Plan
resource "aws_api_gateway_usage_plan_key" "clients" {
  for_each = aws_api_gateway_api_key.clients
  key_id        = aws_api_gateway_api_key.clients[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

# Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id

  triggers = {
    redeployment = sha1(jsonencode([
      "manual-deploy-trigger",
      local.api_clients,
      var.cloud_platform_launchpad_auth_api_url,
      md5(file("api_gateway.tf")),
    ]))
  }

  depends_on = [
    aws_api_gateway_method.oauth2_proxy,
    aws_api_gateway_integration.oauth2_proxy,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  stage_name    = var.namespace

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      extendedRequestId = "$context.extendedRequestId"
      ip                = "$context.identity.sourceIp"
      requestTime       = "$context.requestTime"
      httpMethod        = "$context.httpMethod"
      resourcePath      = "$context.resourcePath"
      status            = "$context.status"
      responseLength    = "$context.responseLength"
      error             = "$context.error.message"
      apiKeyId          = "$context.identity.apiKeyId"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_deployment.main,
    aws_cloudwatch_log_group.api_gateway_access_logs
  ]

  tags = local.default_tags
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api_gateway_lp_auth.id}/${var.namespace}"
  retention_in_days = 60
  tags              = local.default_tags
}

# Method Settings
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = false
  }
}

# The block below creates an ACM certificate (DNS validation), Route53 validation records,
# a regional API Gateway custom domain and an alias record. Enables
# ${var.hostname}.${var.base_domain} to point at the API Gateway.

data "aws_route53_zone" "hmpps" {
  name         = var.base_domain
  private_zone = false
}

resource "aws_acm_certificate" "api_gateway_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = local.default_tags
}

resource "aws_route53_record" "cert_validations" {
  for_each = {
    for dvo in aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.hmpps.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "api_gateway_custom_hostname" {
  for_each = aws_route53_record.cert_validations

  certificate_arn         = aws_acm_certificate.api_gateway_custom_hostname.arn
  validation_record_fqdns = [aws_route53_record.cert_validations[each.key].fqdn]

  timeouts {
    create = "10m"
  }
  depends_on = [aws_route53_record.cert_validations]
}

resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  for_each = aws_acm_certificate_validation.api_gateway_custom_hostname

  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname[each.key].certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  # No mTLS for launchpad-dev by default (omit mutual_tls_authentication)
  depends_on = [
    aws_acm_certificate_validation.api_gateway_custom_hostname
  ]
  tags = local.default_tags
}

resource "aws_route53_record" "data" {
  for_each = aws_api_gateway_domain_name.api_gateway_fqdn

  zone_id = data.aws_route53_zone.hmpps.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.hmpps.name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].regional_zone_id
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_base_path_mapping" "hostname" {
  for_each = aws_api_gateway_domain_name.api_gateway_fqdn

  api_id      = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  domain_name = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].domain_name
  stage_name  = aws_api_gateway_stage.main.stage_name

  depends_on = [
    aws_api_gateway_domain_name.api_gateway_fqdn
  ]
}
