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

  statement {
    sid = "AllowDCSToSendMessageToNotifyQueue"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      module.claim-criminal-injuries-notify-queue.sqs_arn
    ]
  }

  statement {
    sid = "AllowDCSToWriteToS3"
    actions = [
      "s3:PutObject",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_ssm_parameter.cica_stag_account_id.value]
    }
  }
}

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "dcs" {
  name = "dcs-${random_id.id.hex}"
  path = "/system/cica-dcs-user/"
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
    user_arn          = aws_iam_user.dcs.arn
    access_key_id     = aws_iam_access_key.dcs.id
    secret_access_key = aws_iam_access_key.dcs.secret
  }
}

data "aws_iam_policy_document" "app_service_access" {
  statement {
    sid = "AllowAppServiceToReadFromAppQueue"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      module.claim-criminal-injuries-application-queue.sqs_arn
    ]
  }

  statement {
    sid = "AllowAppServiceToWriteToTempusQueue"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      module.claim-criminal-injuries-tempus-queue.sqs_arn
    ]
  }

  statement {
    sid = "AllowAppServiceToWriteToS3"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_ssm_parameter.cica_stag_account_id.value]
    }
  }
}

resource "aws_iam_user" "app_service" {
  name = "app_service-${random_id.id.hex}"
  path = "/system/cica-app-service-user/"
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
    user_arn          = aws_iam_user.app_service.arn
    access_key_id     = aws_iam_access_key.app_service.id
    secret_access_key = aws_iam_access_key.app_service.secret
  }
}

data "aws_iam_policy_document" "redrive_service_access" {
  statement {
    sid = "AllowRedriveServiceToReadFromAppDLQ"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      module.claim-criminal-injuries-application-dlq.sqs_arn
    ]
  }

  statement {
    sid = "AllowRedriveServiceToReadFromNotifyDLQ"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      module.claim-criminal-injuries-notify-dlq.sqs_arn
    ]
  }

  statement {
    sid = "AllowRedriveServiceToSendToAppQueue"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      module.claim-criminal-injuries-application-queue.sqs_arn
    ]
  }

  statement {
    sid = "AllowRedriveServiceToSendToNotifyQueue"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      module.claim-criminal-injuries-notify-queue.sqs_arn
    ]
  }
}

resource "aws_iam_user" "redrive_service" {
  name = "redrive_service-${random_id.id.hex}"
  path = "/system/cica-redrive-service-user/"
}

resource "aws_iam_access_key" "redrive_service" {
  user = aws_iam_user.redrive_service.name
}

resource "aws_iam_user_policy" "redrive_service_policy" {
  name   = "redrive_service_access_policy"
  policy = data.aws_iam_policy_document.redrive_service_access.json
  user   = aws_iam_user.redrive_service.name
}

resource "kubernetes_secret" "redrive-service-sqs-secret" {
  metadata {
    name      = "redrive-service-sqs-secret"
    namespace = var.namespace
  }

  data = {
    user_arn          = aws_iam_user.redrive_service.arn
    access_key_id     = aws_iam_access_key.redrive_service.id
    secret_access_key = aws_iam_access_key.redrive_service.secret
  }
}

data "aws_iam_policy_document" "notify_gateway_access" {
  statement {
    sid = "AllowNotifyGatewayToReadFromNotifyQueue"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      module.claim-criminal-injuries-notify-queue.sqs_arn
    ]
  }
}

resource "aws_iam_user" "notify_gateway" {
  name = "notify_gateway-${random_id.id.hex}"
  path = "/system/cica-notify-gateway-user/"
}

resource "aws_iam_access_key" "notify_gateway" {
  user = aws_iam_user.notify_gateway.name
}

resource "aws_iam_user_policy" "notify_gateway_policy" {
  name   = "notify_gateway_access_policy"
  policy = data.aws_iam_policy_document.notify_gateway_access.json
  user   = aws_iam_user.notify_gateway.name
}

resource "kubernetes_secret" "notify-gateway-sqs-secret" {
  metadata {
    name      = "notify-gateway-sqs-secret"
    namespace = var.namespace
  }

  data = {
    user_arn          = aws_iam_user.notify_gateway.arn
    access_key_id     = aws_iam_access_key.notify_gateway.id
    secret_access_key = aws_iam_access_key.notify_gateway.secret
  }
}
