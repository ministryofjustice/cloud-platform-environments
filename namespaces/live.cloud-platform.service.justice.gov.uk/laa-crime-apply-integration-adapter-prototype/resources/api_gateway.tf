resource "aws_apigatewayv2_api" "gateway" {
  name = var.api_gateway_name
  protocol_type = "HTTP"

  tags = {
    GithubTeam = var.team_name
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
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.gateway.id
  name   = var.apigw_stage_name
}