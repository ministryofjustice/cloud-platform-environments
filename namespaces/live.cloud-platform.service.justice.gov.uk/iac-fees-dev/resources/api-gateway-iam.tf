# Generate an additional IAM user to manage APIGW
resource "random_id" "apigw-id" {
  byte_length = 16
}

resource "aws_iam_user" "apigw-user" {
  name = "apigw-user-${random_id.apigw-id.hex}"
  path = "/system/apigw-user/"
}

resource "aws_iam_access_key" "apigw-user" {
  user = aws_iam_user.apigw-user.name
}

data "aws_iam_policy_document" "apigw" {
  statement {
    actions = [
      "apigateway:PUT",
      "apigateway:GET"
    ]

    resources = [
      aws_api_gateway_rest_api.upload_pdf_api.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_user_policy" "apigw-policy" {
  name   = "${var.namespace}-apigw"
  policy = data.aws_iam_policy_document.apigw.json
  user   = aws_iam_user.apigw-user.name
}

resource "kubernetes_secret" "iac_fees_apigw_iam" {
  metadata {
    name      = "apigateway-iam"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.apigw-user.id
    secret_access_key = aws_iam_access_key.apigw-user.secret
  }
}
