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
  disable_execute_api_endpoint = false

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_resource" "sqs_parent_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_resource" "sqs_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.sqs_parent_resource.id
  path_part   = "get-events"
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

resource "aws_api_gateway_method" "sqs_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.sqs_resource.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true

  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_resource.sqs_parent_resource,
    aws_api_gateway_resource.sqs_resource
  ]
}

resource "aws_api_gateway_method_response" "sqs_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.sqs_resource.id
  http_method = aws_api_gateway_method.sqs_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
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
    "integration.request.path.proxy"                        = "method.request.path.proxy",
    "integration.request.header.subject-distinguished-name" = "context.identity.clientCert.subjectDN"
  }
}

resource "aws_api_gateway_integration" "sqs_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.sqs_resource.id
  http_method             = aws_api_gateway_method.sqs_method.http_method
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${module.event_test_client_queue.sqs_name}?Action=ReceiveMessage"

  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_resource.sqs_parent_resource,
    aws_api_gateway_resource.sqs_resource,
    module.event_test_client_queue,
    aws_api_gateway_method.sqs_method,
    aws_api_gateway_method_response.sqs_method_response,
  ]

  credentials = aws_iam_role.api_gateway_sqs_role.arn
}

resource "aws_api_gateway_integration_response" "sqs_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.sqs_resource.id
  http_method = aws_api_gateway_method.sqs_method.http_method
  status_code = aws_api_gateway_method_response.sqs_method_response.status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_integration.sqs_integration
  ]
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
    aws_api_gateway_method.sqs_method,
    aws_api_gateway_integration.proxy_http_proxy,
    aws_api_gateway_integration.sqs_integration,
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
      "extendedRequestId"  = "$context.extendedRequestId"
      "ip"                 = "$context.identity.sourceIp"
      "client"             = "$context.identity.clientCert.subjectDN"
      "issuerDN"           = "$context.identity.clientCert.issuerDN"
      "requestTime"        = "$context.requestTime"
      "httpMethod"         = "$context.httpMethod"
      "resourcePath"       = "$context.resourcePath"
      "status"             = "$context.status"
      "responseLength"     = "$context.responseLength"
      "error"              = "$context.error.message"
      "authenticateStatus" = "$context.authenticate.status"
      "authenticateError"  = "$context.authenticate.error"
      "integrationStatus"  = "$context.integration.status"
      "integrationError"   = "$context.integration.error"
      "apiKeyId"           = "$context.identity.apiKeyId"
    })
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway_access_logs]
}

resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api_gateway.id}/${var.namespace}"
  retention_in_days = 7
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_cloudwatch_metric_alarm" "gateway_4XX_error_rate" {
  alarm_name          = "${var.namespace}-gateway-4XX-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "Gateway 4xx error greater than 0"
  treat_missing_data  = "notBreaching"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = 30
  evaluation_periods  = 1
  threshold           = 1
  statistic           = "Sum"
  unit                = "Count"
  actions_enabled     = true
  alarm_actions       = [module.sns_topic.topic_arn]
  dimensions = {
    ApiName = var.namespace
  }

  depends_on = [
    module.sns_topic
  ]
}

resource "aws_cloudwatch_metric_alarm" "gateway_5XX_error_rate" {
  alarm_name          = "${var.namespace}-gateway-5XX-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "Gateway 5xx error greater than 0"
  treat_missing_data  = "notBreaching"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 30
  evaluation_periods  = 1
  threshold           = 1
  statistic           = "Sum"
  unit                = "Count"
  actions_enabled     = true
  alarm_actions       = [module.sns_topic.topic_arn]
  dimensions = {
    ApiName = var.namespace
  }

   depends_on = [
    module.sns_topic
  ]
}

resource "aws_cloudwatch_metric_alarm" "gateway_integration_latency" {
  alarm_name          = "${var.namespace}-gateway-integration-latency-greater-than-3-seconds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "Gateway integration latency greater than 3 seconds"
  treat_missing_data  = "notBreaching"
  metric_name         = "IntegrationLatency"
  namespace           = "AWS/ApiGateway"
  period              = 60
  evaluation_periods  = 1
  threshold           = 3000
  statistic           = "Maximum"
  unit                = "Count"
  actions_enabled     = true
  alarm_actions       = [module.sns_topic.topic_arn]
  dimensions = {
    ApiName = var.namespace
  }

   depends_on = [
    module.sns_topic
  ]
}

resource "aws_cloudwatch_metric_alarm" "gateway_latency" {
  alarm_name          = "${var.namespace}-gateway-latency-greater-than-5-seconds"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "Gateway latency greater than 3 seconds"
  treat_missing_data  = "notBreaching"
  metric_name         = "IntegrationLatency"
  namespace           = "AWS/ApiGateway"
  period              = 60
  evaluation_periods  = 1
  threshold           = 5000
  statistic           = "Maximum"
  unit                = "Count"
  actions_enabled     = true
  alarm_actions       = [module.sns_topic.topic_arn]
  dimensions = {
    ApiName = var.namespace
  }

   depends_on = [
    module.sns_topic
  ]
}

module "sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "integration-api-alert-topic"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london_without_default_tags
  }
}

module "notify_slack" {
  source = "github.com/terraform-aws-modules/terraform-aws-notify-slack.git?ref=v5.6.0"

  sns_topic_name   = module.sns_topic.topic_name
  create_sns_topic = false

  lambda_function_name = "${var.namespace}-cloudwatch-alarm-notify-slack"

  cloudwatch_log_group_retention_in_days = 7

  slack_webhook_url = data.aws_secretsmanager_secret_version.slack_webhook_url.secret_string
  slack_channel     = "#hmpps-integration-api-alerts"
  slack_username    = "aws"
  slack_emoji       = ":warning:"
}