resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri = "s3://${module.truststore_s3_bucket.bucket_name}/${aws_s3_object.truststore.id}"
  }

  depends_on = [aws_acm_certificate_validation.api_gateway_custom_hostname]
}

resource "aws_acm_certificate" "api_gateway_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api_gateway_custom_hostname" {
  certificate_arn         = aws_acm_certificate.api_gateway_custom_hostname.arn
  validation_record_fqdns = aws_route53_record.cert_validations[*].fqdn

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

  name    = element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options[*].resource_record_name, count.index)
  type    = element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options[*].resource_record_type, count.index)
  records = [element(aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options[*].resource_record_value, count.index)]
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
  name                         = var.namespace
  disable_execute_api_endpoint = true

  endpoint_configuration {
    types = ["REGIONAL"]
  }
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

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "${var.cloud_platform_integration_api_url}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "development" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  # Force recreate of the deployment resource
  stage_description = md5(file("api_gateway.tf"))

  depends_on = [
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
    stage  = aws_api_gateway_stage.development.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "team" {
  key_id        = aws_api_gateway_api_key.team.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

# This block gets around the deprecation notice/ambiguous interpolation warning when using
# a variable for a key
locals {
  api_keys_data = {
    for team_name in [var.team_name] :
    team_name => aws_api_gateway_api_key.team.value
  }
}

resource "kubernetes_secret" "api_keys" {
  metadata {
    name      = "api-gateway-api-keys"
    namespace = var.namespace
  }

  data = local.api_keys_data
}

resource "aws_api_gateway_base_path_mapping" "hostname" {
  api_id      = aws_api_gateway_rest_api.api_gateway.id
  domain_name = aws_api_gateway_domain_name.api_gateway_fqdn.domain_name
  stage_name  = aws_api_gateway_stage.development.stage_name
}

resource "aws_api_gateway_client_certificate" "api_gateway_client" {
  description = "Client certificate presented to the backend API"
}

resource "kubernetes_secret" "api_gateway_client_certificate_secret" {
  metadata {
    name      = "api-gateway-client-certificate"
    namespace = var.namespace
  }

  data = {
    certificate = aws_api_gateway_client_certificate.api_gateway_client.pem_encoded_certificate
  }
}

resource "aws_api_gateway_stage" "development" {
  deployment_id = aws_api_gateway_deployment.development.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.namespace
  client_certificate_id = aws_api_gateway_client_certificate.api_gateway_client.id
}
