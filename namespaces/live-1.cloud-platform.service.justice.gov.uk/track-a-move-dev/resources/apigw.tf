resource "aws_api_gateway_rest_api" "apigw" {
  name = "track-a-move"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "tracking" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  path_part   = "tracking"
}


resource "aws_api_gateway_resource" "supplier_param" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  parent_id   = aws_api_gateway_resource.tracking.id
  path_part   = "{supplier}"
}
