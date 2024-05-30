resource "aws_api_gateway_resource" "sqs_pnd_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.sqs_parent_resource.id
  path_part   = "pnd"
}
resource "aws_api_gateway_method" "sqs_pnd_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.sqs_pnd_resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_resource.sqs_parent_resource,
    aws_api_gateway_resource.sqs_pnd_resource
  ]
}

resource "aws_api_gateway_method_response" "sqs_pnd_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.sqs_pnd_resource.id
  http_method = aws_api_gateway_method.sqs_pnd_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_iam_role" "api_gateway_sqs_pnd_role" {
  name               = "${var.namespace}-api-gateway-sqs-pnd-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api_gateway_sqs_pnd_policy" {
  name = "${var.namespace}-api-gateway-sqs-pnd-policy"
  role = aws_iam_role.api_gateway_sqs_pnd_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:ReceiveMessage"
        Resource = module.event_pnd_queue.sqs_arn
      }
    ]
  })
}

resource "aws_api_gateway_integration" "sqs_pnd_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.sqs_pnd_resource.id
  http_method             = aws_api_gateway_method.sqs_pnd_method.http_method
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${module.event_pnd_queue.sqs_name}?Action=ReceiveMessage"

  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_resource.sqs_parent_resource,
    aws_api_gateway_resource.sqs_pnd_resource,
    module.event_pnd_queue,
    aws_api_gateway_method.sqs_pnd_method,
    aws_api_gateway_method_response.sqs_pnd_method_response,
  ]

  credentials = aws_iam_role.api_gateway_sqs_pnd_role.arn
}

resource "aws_api_gateway_integration_response" "sqs_pnd_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.sqs_pnd_resource.id
  http_method = aws_api_gateway_method.sqs_pnd_method.http_method
  status_code = aws_api_gateway_method_response.sqs_pnd_method_response.status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_integration.sqs_pnd_integration
  ]
}