resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [aws_acm_certificate_validation.api_gateway_custom_hostname]
}

resource "aws_acm_certificate" "api_gateway_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "api_gateway_custom_hostname" {
  certificate_arn         = aws_acm_certificate.api_gateway_custom_hostname.arn
  validation_record_fqdns = aws_route53_record.cert_validations.*.fqdn

  timeouts {
    create = "10m"
  }

  depends_on = [aws_route53_record.cert_validations]
}

data "aws_route53_zone" "hmpps" {
  name         = var.base_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validations" {
  count = length(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options)

  zone_id = data.aws_route53_zone.hmpps.zone_id

  name    = element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options.*.resource_record_type, count.index)
  records = [element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = 60
}

resource "aws_route53_record" "data" {
  zone_id = data.aws_route53_zone.hmpps.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.hmpps.name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_fqdn.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_fqdn.regional_zone_id
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name = var.namespace

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  path        = "/"
}

resource "aws_api_gateway_method" "root" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = data.aws_api_gateway_resource.root.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "root_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.root.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = var.cloud_platform_integration_api_url
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "proxy_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = var.cloud_platform_integration_api_url
}

resource "aws_api_gateway_deployment" "development" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = "development"

  # Force recreate of the deployment resource
  stage_description = md5(file("api_gateway.tf"))

  depends_on = [
    aws_api_gateway_method.root,
    aws_api_gateway_integration.root_http_proxy,
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.proxy_http_proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_api_key" "team" {
  name = var.team_name
}

resource "aws_api_gateway_usage_plan" "default" {
  name = var.namespace

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_deployment.development.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "team" {
  key_id        = aws_api_gateway_api_key.team.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}


resource "kubernetes_secret" "api_keys" {
  metadata {
    name      = "api-gateway-api-keys"
    namespace = var.namespace
  }

  data = {
    "${var.team_name}" = aws_api_gateway_api_key.team.value
  }
}
