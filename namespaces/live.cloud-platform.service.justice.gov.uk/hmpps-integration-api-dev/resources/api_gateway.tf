resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  for_each = aws_acm_certificate_validation.api_gateway_custom_hostname

  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname[each.key].certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri     = "s3://${module.truststore_s3_bucket.bucket_name}/${aws_s3_object.truststore.id}"
    truststore_version = aws_s3_object.truststore.version_id
  }

  depends_on = [
    aws_acm_certificate_validation.api_gateway_custom_hostname,
    aws_s3_object.truststore
  ]
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
    "integration.request.path.proxy" = "method.request.path.proxy",
    "integration.request.header.subject-distinguished-name" = "context.identity.clientCert.subjectDN"
  }
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      # "manual-deploy-trigger",
      local.clients,
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
  name     = each.key
}

resource "aws_api_gateway_usage_plan" "default" {
  name = var.namespace

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_stage.main.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "clients" {
  for_each = aws_api_gateway_api_key.clients

  key_id        = aws_api_gateway_api_key.clients[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_base_path_mapping" "hostname" {
  for_each = aws_api_gateway_domain_name.api_gateway_fqdn

  api_id      = aws_api_gateway_rest_api.api_gateway.id
  domain_name = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].domain_name
  stage_name  = aws_api_gateway_stage.main.stage_name
}

resource "aws_api_gateway_client_certificate" "api_gateway_client" {
  description = "Client certificate presented to the backend API"
}

resource "aws_api_gateway_stage" "main" {
  deployment_id         = aws_api_gateway_deployment.main.id
  rest_api_id           = aws_api_gateway_rest_api.api_gateway.id
  stage_name            = var.namespace
  client_certificate_id = aws_api_gateway_client_certificate.api_gateway_client.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      extendedRequestId  = "$context.extendedRequestId"
      ip                 = "$context.identity.sourceIp"
      client             = "$context.identity.clientCert.subjectDN"
      issuerDN           = "$context.identity.clientCert.issuerDN"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      resourcePath       = "$context.resourcePath"
      status             = "$context.status"
      responseLength     = "$context.responseLength"
      error              = "$context.error.message"
      authenticateStatus = "$context.authenticate.status"
      authenticateError  = "$context.authenticate.error"
      integrationStatus  = "$context.integration.status"
      integrationError   = "$context.integration.error"
      apiKeyId           = "$context.identity.apiKeyId"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.default_tags
  
  providers = {
    aws = aws.london_without_default_tags
  }
  depends_on = [aws_cloudwatch_log_group.api_gateway_access_logs]
}

resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api_gateway.id}/${var.namespace}"
  retention_in_days = 60
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    data_trace_enabled = true
  }
}
