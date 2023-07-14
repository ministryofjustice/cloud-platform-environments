resource "aws_api_gateway_domain_name" "api_gateway_fqdn" {
  for_each = aws_acm_certificate_validation.api_gateway_custom_hostname

  domain_name              = aws_acm_certificate.api_gateway_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.api_gateway_custom_hostname[each.key].certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri     = "s3://${module.s3_bucket.bucket_name}/${aws_s3_object.truststore.id}"
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

data "aws_route53_zone" "iac_fees" {
  name         = var.base_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validations" {
  for_each = {
    for dvo in aws_acm_certificate.api_gateway_custom_hostname.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.iac_fees.zone_id
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

  zone_id = data.aws_route53_zone.iac_fees.zone_id
  name    = "${var.hostname}.${data.aws_route53_zone.iac_fees.name}"
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
  binary_media_types           = ["*/*"]

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_api_gateway_rest_api_policy" "api_policy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "arn:aws:execute-api:eu-west-2:754256621582:gp3sc513hg/*/*/*"
      }
    ]
  }
  EOF
}

resource "aws_api_gateway_resource" "bucket" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{bucket}"
}

resource "aws_api_gateway_resource" "upload_type" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.bucket.id
  path_part   = "{upload_type}"
}

resource "aws_api_gateway_resource" "filetype" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.upload_type.id
  path_part   = "{filetype}"
}

resource "aws_api_gateway_resource" "filename" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.filetype.id
  path_part   = "{filename}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.bucket"      = true
    "method.request.path.upload_type" = true
    "method.request.path.filetype"    = true
    "method.request.path.filename"    = true
  }
}

resource "aws_api_gateway_integration" "proxy_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.filename.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "AWS"
  integration_http_method = "PUT"
  uri                     = "arn:aws:apigateway:eu-west-2:s3:action/PutObject/cloud-platform-d3ad47215cc1ffea9eff85a1aa2575b6/"

  credentials = aws_iam_role.api_gateway_role.arn

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "api_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.api_method_response.status_code
  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_integration.proxy_http_proxy
  ]
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  #hack to force recreate of the deployment resource
  stage_description = md5(file("api-gateway.tf"))

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.proxy_http_proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
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
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"
  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
    data_trace_enabled     = false
  }
}
