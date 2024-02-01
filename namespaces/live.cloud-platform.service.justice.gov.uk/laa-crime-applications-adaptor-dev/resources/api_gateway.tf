resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name              = "API-Gateway-Execution-Logs_caa_api_dev"
  retention_in_days = 60
}

resource "aws_apigatewayv2_api" "gateway" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_apigatewayv2_authorizer" "auth" {
  api_id           = aws_apigatewayv2_api.gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.maat_client.id]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }

}

resource "aws_apigatewayv2_integration" "crime_apply_api_dev" {
  api_id             = aws_apigatewayv2_api.gateway.id
  integration_method = "ANY"
  connection_type    = "INTERNET"
  integration_type   = "HTTP_PROXY"
  integration_uri    = "https://laa-crime-applications-adaptor-dev.apps.live.cloud-platform.service.justice.gov.uk/api/internal/v1/crimeapply/{proxy}"

  depends_on = [
    aws_apigatewayv2_api.gateway,
  ]

}

resource "aws_apigatewayv2_route" "route" {
  api_id               = aws_apigatewayv2_api.gateway.id
  route_key            = "ANY /api/internal/v1/crimeapply/{proxy+}"
  target               = "integrations/${aws_apigatewayv2_integration.crime_apply_api_dev.id}"
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.auth.id
  authorization_scopes = aws_cognito_resource_server.resource.scope_identifiers

  depends_on = [
    aws_apigatewayv2_api.gateway,
    aws_apigatewayv2_integration.crime_apply_api_dev,
  ]

}

resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = aws_apigatewayv2_api.gateway.id
  description = "API Gateway deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.gateway,
    aws_apigatewayv2_integration.crime_apply_api_dev,
    aws_apigatewayv2_route.route
  ]
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id        = aws_apigatewayv2_api.gateway.id
  name          = var.apigw_stage_name
  deployment_id = aws_apigatewayv2_deployment.deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
    format = jsonencode(
      {
        requestId         = "$context.requestId"
        extendedRequestId = "$context.extendedRequestId"
        ip                = "$context.identity.sourceIp"
        caller            = "$context.identity.caller"
        user              = "$context.identity.user"
        requestTime       = "$context.requestTime"
        httpMethod        = "$context.httpMethod"
        resourcePath      = "$context.resourcePath"
        status            = "$context.status"
        protocol          = "$context.protocol"
        responseLength    = "$context.responseLength"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.gateway,
    aws_apigatewayv2_deployment.deployment
  ]

  default_route_settings {
    logging_level            = "INFO"
    detailed_metrics_enabled = true
    throttling_rate_limit    = 100
    throttling_burst_limit   = 100
  }

}