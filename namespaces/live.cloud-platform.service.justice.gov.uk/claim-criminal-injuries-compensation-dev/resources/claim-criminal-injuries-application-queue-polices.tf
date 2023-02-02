data "aws_iam_policy_document" "dcs_access" {
  statement {
    sid = "AllowDCSToSendMessageToAppQueue"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      module.claim-criminal-injuries-application-queue.sqs_arn
    ]
  }
}

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "dcs" {
  name = "dcs-${random_id.id.hex}"
  path = "/system/cica-dcs-user"
}

resource "aws_iam_access_key" "dcs" {
  user = aws_iam_user.dcs.name
}

resource "aws_iam_user_policy" "dcs_policy" {
  name   = "dcs_access_policy"
  policy = data.aws_iam_policy_document.dcs_access.json
  user   = aws_iam_user.dcs.name
}

resource "kubernetes_secret" "dcs-sqs-secret" {
  metadata {
    name      = "dcs-sqs-secret"
    namespace = var.namespace
  }

  data = {
    user_arn           = aws_iam_user.dcs.arn
    access_key_id      = aws_iam_access_key.dcs.id
    secret_access_key  = aws_iam_access_key.dcs.secret
  }
}

data "aws_iam_policy_document" "app_service_access" {
  statement {
    sid = "AllowAppServiceToReadFromAppQueue"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [
      module.claim-criminal-injuries-application-queue.sqs_arn
    ]
  }
}

resource "aws_iam_user" "app_service" {
  name = "app_service-${random_id.id.hex}"
  path = "/system/cica-app-service-user"
}

resource "aws_iam_access_key" "app_service" {
  user = aws_iam_user.app_service.name
}

resource "aws_iam_user_policy" "app_service_policy" {
  name   = "app_service_access_policy"
  policy = data.aws_iam_policy_document.app_service_access.json
  user   = aws_iam_user.app_service.name
}

resource "kubernetes_secret" "app-service-sqs-secret" {
  metadata {
    name      = "app-service-sqs-secret"
    namespace = var.namespace
  }

  data = {
    user_arn           = aws_iam_user.app_service.arn
    access_key_id      = aws_iam_access_key.app_service.id
    secret_access_key  = aws_iam_access_key.app_service.secret
  }
}