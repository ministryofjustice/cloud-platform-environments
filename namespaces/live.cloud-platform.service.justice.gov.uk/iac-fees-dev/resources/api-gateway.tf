resource "aws_api_gateway_domain_name" "apigw_fqdn" {
  domain_name              = aws_acm_certificate.apigw_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.apigw_custom_hostname.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [aws_acm_certificate_validation.apigw_custom_hostname]
}

resource "aws_acm_certificate" "apigw_custom_hostname" {
  domain_name       = "${var.hostname}.${var.base_domain}"
  validation_method = "DNS"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "apigw_custom_hostname" {
  depends_on              = [aws_acm_certificate.apigw_custom_hostname, aws_route53_record.cert_validations]
  certificate_arn         = aws_acm_certificate.apigw_custom_hostname.arn
  validation_record_fqdns = aws_route53_record.cert_validations[*].fqdn

  timeouts {
    create = "5m"
  }
}

data "aws_route53_zone" "hmpps" {
  name         = var.base_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validations" {
  count = length(aws_acm_certificate.apigw_custom_hostname.domain_validation_options)

  zone_id = data.kubernetes_secret.zone_id.data["zone_id"]

  name    = element(aws_acm_certificate.apigw_custom_hostname.domain_validation_options[*].resource_record_name, count.index)
  type    = element(aws_acm_certificate.apigw_custom_hostname.domain_validation_options[*].resource_record_type, count.index)
  records = [element(aws_acm_certificate.apigw_custom_hostname.domain_validation_options[*].resource_record_value, count.index)]
  ttl     = 60
}

resource "aws_route53_record" "data" {
  name    = aws_api_gateway_domain_name.apigw_fqdn.domain_name
  type    = "A"
  zone_id = data.kubernetes_secret.zone_id.data["zone_id"]

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.apigw_fqdn.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.apigw_fqdn.regional_zone_id
  }
}


resource "aws_api_gateway_rest_api" "upload_files_api" {
  name        = "iac-fees-upload-files-api"
  description = "API Gateway to connect and upload files to S3"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.upload_files_api.id
  parent_id   = aws_api_gateway_rest_api.upload_files_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.upload_files_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.upload_files_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  type        = "AWS"

  integration_http_method = "PUT"
  uri                     = "arn:aws:apigateway:eu-west-2:s3:action/PutObject/cloud-platform-d3ad47215cc1ffea9eff85a1aa2575b6/"

  credentials = aws_iam_role.api_gateway_role.arn

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_deployment" "live" {
  rest_api_id = aws_api_gateway_rest_api.upload_files_api.id
  stage_name  = "live"

  stage_description = md5(file("api-gateway.tf"))

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_api_gateway_api_key" "clients" {
#   for_each = toset(local.clients)
#   name = each.key
# }

# resource "aws_api_gateway_usage_plan" "default" {
#   name = var.namespace

#   api_stages {
#     api_id = aws_api_gateway_rest_api.api_gateway.id
#     stage  = aws_api_gateway_stage.main.stage_name
#   }
# }

# resource "aws_api_gateway_usage_plan_key" "clients" {
#   for_each      = aws_api_gateway_api_key.clients

#   key_id        = aws_api_gateway_api_key.clients[each.key].id
#   key_type      = "API_KEY"
#   usage_plan_id = aws_api_gateway_usage_plan.default.id
# }

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
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.namespace
  client_certificate_id = aws_api_gateway_client_certificate.api_gateway_client.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format          = jsonencode({
      "extendedRequestId" = "$context.extendedRequestId"
      "ip" =  "$context.identity.sourceIp"
      "client" = "$context.identity.clientCert.subjectDN"
      "issuerDN" = "$context.identity.clientCert.issuerDN"
      "requestTime" = "$context.requestTime"
      "httpMethod" = "$context.httpMethod"
      "resourcePath" = "$context.resourcePath"
      "status" = "$context.status"
      "responseLength" = "$context.responseLength"
      "error" = "$context.error.message"
      "authenticateStatus" = "$context.authenticate.status"
      "authenticateError" = "$context.authenticate.error"
      "integrationStatus" = "$context.integration.status"
      "integrationError" = "$context.integration.error"
      "apiKeyId" = "$context.identity.apiKeyId"
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

resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.upload_files_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "proxy" {
  depends_on = [
    aws_api_gateway_integration.proxy
  ]
  rest_api_id = aws_api_gateway_rest_api.upload_files_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api-gateway-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_put_object_policy" {
  name        = "s3-put-object-policy"
  description = "Allows API Gateway to put objects in S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPutObject",
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::cloud-platform-d3ad47215cc1ffea9eff85a1aa2575b6/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "api_gateway_s3_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.s3_put_object_policy.arn
}
