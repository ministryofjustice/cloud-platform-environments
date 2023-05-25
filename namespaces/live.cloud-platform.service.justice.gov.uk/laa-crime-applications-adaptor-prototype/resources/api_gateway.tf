resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_apigatewayv2_api.gateway.id}/v1"
  retention_in_days = 60
}

resource "aws_apigatewayv2_api" "gateway" {
  name = var.api_gateway_name
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
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

resource "aws_apigatewayv2_integration" "test_api" {
  api_id                          = aws_apigatewayv2_api.gateway.id
  integration_method              = "ANY"
  connection_type                 = "INTERNET"
  integration_type                = "HTTP_PROXY"
  integration_uri                 = "https://${aws_apigatewayv2_api.gateway.id}.execute-api.${var.apigw_region}.amazonaws.com/${var.apigw_stage_name}/test"
  passthrough_behavior            = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "ANY /test"
  target = "integrations/${aws_apigatewayv2_integration.test_api.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id
  authorization_scopes = aws_cognito_resource_server.resource.scope_identifiers
}

resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = aws_apigatewayv2_api.gateway.id
  description = "API Gateway deployment"

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.test_api),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.gateway,
    aws_apigatewayv2_route.route,
    aws_apigatewayv2_integration.test_api,
  ]
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.gateway.id
  name   = var.apigw_stage_name
  deployment_id = aws_apigatewayv2_deployment.deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
    format          = jsonencode(
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
    logging_level = "INFO"
    detailed_metrics_enabled = true
  }

}

resource "aws_api_gateway_usage_plan" "caa-plan" {
  name = "caa-prototype-usage-plan"
  description = "API gateway usage plan for CAA service."

  quota_settings {
    limit = 500
    offset = 2
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 20
    rate_limit = 10
  }

  api_stages {
    api_id = aws_apigatewayv2_api.gateway.id
    stage = var.apigw_stage_name
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.gateway,
  ]
}
