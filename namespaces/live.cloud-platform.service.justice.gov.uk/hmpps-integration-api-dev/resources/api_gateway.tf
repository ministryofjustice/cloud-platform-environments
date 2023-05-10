resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  for_each = aws_acm_certificate_validation.api_gateway_custom_hostname

  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname[each.key].certificate_arn
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
  for_each = aws_route53_record.cert_validations

  certificate_arn         = aws_acm_certificate.api_gateway_custom_hostname.arn
  validation_record_fqdns = [aws_route53_record.cert_validations[each.key].fqdn]

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

resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      # "manual-deploy-trigger",
      var.cloud_platform_integration_api_url,
      md5(file("api_gateway.tf"))
    ]))
  }

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.proxy_http_proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_api_key" "clients" {
  for_each = toset(local.clients)
  name = each.key
}

resource "aws_api_gateway_usage_plan" "default" {
  name = var.namespace

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_stage.dev.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "clients" {
  for_each      = aws_api_gateway_api_key.clients

  key_id        = aws_api_gateway_api_key.clients[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "kubernetes_secret" "api_keys" {
  metadata {
    name      = "api-gateway-api-keys"
    namespace = var.namespace
  }

  data = {
    for client in local.clients : client => aws_api_gateway_api_key.clients[client].value
  }

  depends_on = [
    aws_api_gateway_api_key.clients
  ]
}

resource "aws_api_gateway_base_path_mapping" "hostname" {
  for_each = aws_api_gateway_domain_name.api_gateway_fqdn

  api_id      = aws_api_gateway_rest_api.api_gateway.id
  domain_name = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].domain_name
  stage_name  = aws_api_gateway_stage.dev.stage_name
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
    "ca.crt" = aws_api_gateway_client_certificate.api_gateway_client.pem_encoded_certificate
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.namespace
  client_certificate_id = aws_api_gateway_client_certificate.api_gateway_client.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format          = "$context.extendedRequestId $context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol \" $context.status $context.responseLength $context.requestId"
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway_access_logs]
}

resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api_gateway.id}/${var.namespace}"
  retention_in_days = 7
}

resource "kubernetes_secret" "api_gateway_logs" {
  metadata {
    name      = "api-gateway-logs"
    namespace = var.namespace
  }

  data = {
    "access_log_url" = "https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#logsV2:log-groups/log-group/${aws_cloudwatch_log_group.api_gateway_access_logs.name}"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_access_logs
  ]
}

