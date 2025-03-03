resource "aws_api_gateway_resource" "role_assume" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "token"
}

resource "aws_api_gateway_method" "role_assume_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.role_assume.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "sts_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.role_assume.id
  type                    = "AWS"
  http_method             = aws_api_gateway_method.role_assume_method.http_method
  integration_http_method = aws_api_gateway_method.role_assume_method.http_method
  uri                     = "arn:aws:apigateway:us-east-1:sts:action/AssumeRole"
  credentials             = aws_iam_role.sts_integration.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = join("&", [
      "Action=AssumeRole",
      "DurationSeconds=3600",
      "RoleArn=arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.namespace}-sqs",
      "RoleSessionName=$util.urlEncode($context.extendedRequestId)",
      "Tags.member.1.Key=ClientId",
      "Tags.member.1.Value=$context.identity.clientCert.subjectDN.replaceAll('.*,CN=', '')",
      "Version=2011-06-15"
    ])
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_integration_response" "sts_integration" {
  rest_api_id = aws_api_gateway_integration.sts_integration.rest_api_id
  resource_id = aws_api_gateway_integration.sts_integration.resource_id
  http_method = aws_api_gateway_integration.sts_integration.http_method
  status_code = "200"
  response_templates = {
    "application/json" = "$input.json('$.AssumeRoleResponse.AssumeRoleResult.Credentials')"
  }
  depends_on = [aws_api_gateway_method_response.sts_method_response]
}

resource "aws_api_gateway_method_response" "sts_method_response" {
  rest_api_id = aws_api_gateway_integration.sts_integration.rest_api_id
  resource_id = aws_api_gateway_integration.sts_integration.resource_id
  http_method = aws_api_gateway_integration.sts_integration.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_iam_role" "sts_integration" {
  name = "${var.namespace}-sts"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowApiGatewayToAssume"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "sts:AssumeRole",
            "sts:TagSession",
          ],
          Effect = "Allow"
          Sid    = "AllowToAssumeSqsRole"
          Resource = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.namespace}-sqs"]
        }
      ]
    })
  }
}
