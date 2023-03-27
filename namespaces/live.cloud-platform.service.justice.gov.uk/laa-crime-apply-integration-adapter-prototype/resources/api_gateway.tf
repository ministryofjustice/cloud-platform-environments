resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "vpc_link"
  security_group_ids = [var.apigw_sg]
  subnet_ids         = var.VPCSubnets
}

resource "aws_apigatewayv2_api" "gateway" {
  name = var.api_gateway_name
  protocol_type = "HTTP"
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
    connection_id                   = aws_apigatewayv2_vpc_link.vpc_link.id
    connection_type                 = "VPC_LINK"
    integration_method              = "ANY"
    integration_type                = "HTTP_PROXY"
    integration_uri                 = var.aws_lb_listener_https_arn        
    passthrough_behavior            = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "GET /test"
  target = "integrations/${aws_apigatewayv2_integration.test_api.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.gateway.id
  name   = var.apigw_stage_name
}

resource "aws_api_gateway_domain_name" "apigw_fqdn" {
  domain_name              = aws_acm_certificate.apigw_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.apigw_custom_hostname.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [aws_acm_certificate_validation.apigw_custom_hostname]
}