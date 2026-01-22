resource "aws_api_gateway_rest_api" "api_gateway_lp_auth" {
  name = "${var.namespace}-external-auth"
  disable_execute_api_endpoint = false

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

# /v1/oauth2/authorize resource
resource "aws_api_gateway_resource" "authorize" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  parent_id   = aws_api_gateway_resource.oauth2.id
  path_part   = "authorize"
}

# /v1/oauth2/token resource
resource "aws_api_gateway_resource" "token" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  parent_id   = aws_api_gateway_resource.oauth2.id
  path_part   = "token"
}

# GET /v1/oauth2/authorize method
resource "aws_api_gateway_method" "authorize_get" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  resource_id      = aws_api_gateway_resource.authorize.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.querystring.client_id"     = true
    "method.request.querystring.response_type" = true
    "method.request.querystring.redirect_uri"  = true
    "method.request.querystring.nonce"         = true
    "method.request.querystring.state"         = true
  }
}

# GET /v1/oauth2/authorize integration
resource "aws_api_gateway_integration" "authorize_get" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  resource_id             = aws_api_gateway_resource.authorize.id
  http_method             = aws_api_gateway_method.authorize_get.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "${var.launchpad_auth_service_url}/v1/oauth2/authorize"
}

# POST /v1/oauth2/token method
resource "aws_api_gateway_method" "token_post" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  resource_id      = aws_api_gateway_resource.token.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

# POST /v1/oauth2/token integration
resource "aws_api_gateway_integration" "token_post" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_lp_auth.id
  resource_id             = aws_api_gateway_resource.token.id
  http_method             = aws_api_gateway_method.token_post.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "${var.launchpad_auth_service_url}/v1/oauth2/token"

  request_templates = {
    "application/x-www-form-urlencoded" = "$input.body"
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

  quota_settings {
    limit  = var.api_gateway_quota_limit
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = var.api_gateway_burst_limit
    rate_limit  = var.api_gateway_rate_limit
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
      var.launchpad_auth_service_url,
      md5(file("api_gateway.tf")),
    ]))
  }

  depends_on = [
    aws_api_gateway_method.authorize_get,
    aws_api_gateway_method.token_post,
    aws_api_gateway_integration.authorize_get,
    aws_api_gateway_integration.token_post,
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
  name              = "Lauchpad-API-Gateway-Logs_${aws_api_gateway_rest_api.api_gateway_lp_auth.id}/${var.namespace}"
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
    data_trace_enabled = false}
}
