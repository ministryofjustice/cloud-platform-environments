# Generate an additional IAM user to manage API Gateway
resource "random_id" "api_gateway_id" {
  byte_length = 16
}

resource "aws_iam_user" "api_gateway_user" {
  name = "api-gateway-user-${random_id.api_gateway_id.hex}"
  path = "/system/api-gateway-user/"
}

resource "aws_iam_access_key" "api_gateway_user" {
  user = aws_iam_user.api_gateway_user.name
}

data "aws_iam_policy_document" "api_gateway" {
  statement {
    actions = [
      "apigateway:*",
    ]

    resources = [
      "${element(split("/", aws_api_gateway_rest_api.api_gateway.arn), 0)}/*",
    ]
  }
}

resource "aws_iam_user_policy" "api_gateway_policy" {
  name   = "${var.namespace}-api-gateway"
  policy = data.aws_iam_policy_document.api_gateway.json
  user   = aws_iam_user.api_gateway_user.name
}

resource "kubernetes_secret" "api_gateway_admin_user_credentials" {
  metadata {
    name      = "api-gateway-iam"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.api_gateway_user.id
    secret_access_key = aws_iam_access_key.api_gateway_user.secret
  }
}
