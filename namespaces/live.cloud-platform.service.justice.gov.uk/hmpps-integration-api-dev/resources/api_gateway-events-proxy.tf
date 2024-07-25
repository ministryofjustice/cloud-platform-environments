

resource "aws_api_gateway_resource" "events_parent_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "events"

  tags = local.default_tags
}


resource "aws_api_gateway_resource" "event_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.events_parent_resource.id
  path_part   = "{proxy+}"

  tags = local.default_tags
}

resource "aws_api_gateway_method" "event_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.event_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }

  tags = local.default_tags
}

resource "aws_api_gateway_integration" "event_proxy_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.event_proxy.id
  http_method             = aws_api_gateway_method.event_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "${var.cloud_platform_integration_event_url}/events/{proxy}"

  request_parameters = {
    "integration.request.path.proxy"                        = "method.request.path.proxy",
    "integration.request.header.subject-distinguished-name" = "context.identity.clientCert.subjectDN"
  }

  tags = local.default_tags
}
