resource "aws_api_gateway_rest_api" "api_gateway" {
  name                         = var.namespace
  disable_execute_api_endpoint = true

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "${var.cloud_platform_integration_api_url}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "production" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      # "manual-deploy-trigger",
      var.cloud_platform_integration_api_url,
      md5(file("api_gateway.tf"))
    ]))
  }

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.proxy_http_proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_api_key" "clients" {
  for_each = toset(local.clients)
  name = each.key
}

resource "aws_api_gateway_usage_plan" "default" {
  name = var.namespace

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_stage.production.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "clients" {
  for_each      = aws_api_gateway_api_key.clients

  key_id        = aws_api_gateway_api_key.clients[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "kubernetes_secret" "api_keys" {
  metadata {
    name      = "api-gateway-api-keys"
    namespace = var.namespace
  }
  
  data = {
    for client in local.clients : client => aws_api_gateway_api_key.clients[client].value
  }

  depends_on = [
    aws_api_gateway_api_key.clients
  ]
}

resource "aws_api_gateway_client_certificate" "api_gateway_client" {
  description = "Client certificate presented to the backend API"
}

resource "kubernetes_secret" "api_gateway_client_certificate_secret" {
  metadata {
    name      = "api-gateway-client-certificate"
    namespace = var.namespace
  }

  data = {
    "ca.crt" = aws_api_gateway_client_certificate.api_gateway_client.pem_encoded_certificate
  }
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.production.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.namespace
  client_certificate_id = aws_api_gateway_client_certificate.api_gateway_client.id
}
