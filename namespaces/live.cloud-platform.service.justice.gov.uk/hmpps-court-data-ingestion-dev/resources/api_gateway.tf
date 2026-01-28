resource "aws_api_gateway_rest_api" "ingestion_api" {
  name                         = var.namespace
  tags = local.default_tags
}

resource "aws_api_gateway_resource" "ingest" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_api.id
  parent_id   = aws_api_gateway_rest_api.ingestion_api.root_resource_id
  path_part   = "ingest"
}

resource "aws_api_gateway_authorizer" "hmac" {
  name            = "hmac-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.ingestion_api.id
  authorizer_uri  = aws_lambda_function.authorizer.invoke_arn
  type            = "TOKEN"
  identity_source = "method.request.header.X-Signature"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_api.id
  resource_id   = aws_api_gateway_resource.ingest.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.hmac.id
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_api.id
  resource_id = aws_api_gateway_resource.ingest.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_api.id
  resource_id = aws_api_gateway_resource.ingest.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
}


#TODO Unsure of what the deployment needs to be triggered on.
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      "manual-deploy-trigger",
      md5(file("api_gateway.tf")),
      md5(file("api_gateway-sqs-integration.tf")),
    ]))
  }

  depends_on = [
    aws_api_gateway_method.post,
    aws_api_gateway_integration.sqs
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id         = aws_api_gateway_deployment.main.id
  rest_api_id           = aws_api_gateway_rest_api.ingestion_api.id
  stage_name            = var.namespace

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

  depends_on = [
    aws_api_gateway_deployment.main,
    aws_cloudwatch_log_group.api_gateway_access_logs
  ]

  tags = local.default_tags
}


resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.ingestion_api.id}/${var.namespace}"
  retention_in_days = 60
  tags              = local.default_tags
}
