resource "aws_api_gateway_rest_api" "upload_pdf_api" {
  name        = "upload-pdf-api"
  description = "API Gateway to connect and upload PDFs to S3"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.upload_pdf_api.id
  parent_id   = aws_api_gateway_rest_api.upload_pdf_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.upload_pdf_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.upload_pdf_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  type        = "AWS"

  integration_http_method = "PUT"
  uri                     = var.s3_bucket_arn

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.upload_pdf_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.upload_pdf_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

  response_templates = {
    "application/json" = ""
  }
}
