

resource "aws_api_gateway_resource" "sqs_mapps_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.sqs_parent_resource.id
  path_part   = "mapps"
}

resource "aws_api_gateway_method" "sqs_mapps_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.sqs_mapps_resource.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true

  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_resource.sqs_parent_resource,
    aws_api_gateway_resource.sqs_mapps_resource
  ]
}

resource "aws_api_gateway_method_response" "sqs_mapps_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.sqs_mapps_resource.id
  http_method = aws_api_gateway_method.sqs_mapps_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "sqs_mapps_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.sqs_mapps_resource.id
  http_method             = aws_api_gateway_method.sqs_mapps_method.http_method
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${module.event_mapps_queue.sqs_name}?Action=ReceiveMessage"

  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_resource.sqs_parent_resource,
    aws_api_gateway_resource.sqs_mapps_resource,
    module.event_mapps_queue,
    aws_api_gateway_method.sqs_mapps_method,
    aws_api_gateway_method_response.sqs_mapps_method_response,
  ]

  credentials = aws_iam_role.api_gateway_sqs_role.arn
}

resource "aws_api_gateway_integration_response" "sqs_mapps_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.sqs_mapps_resource.id
  http_method = aws_api_gateway_method.sqs_mapps_method.http_method
  status_code = aws_api_gateway_method_response.sqs_mapps_method_response.status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_rest_api.api_gateway,
    aws_api_gateway_integration.sqs_integrsqs_mapps_integrationation
  ]
}