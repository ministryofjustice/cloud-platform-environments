data "aws_iam_policy_document" "ses_send_smtp_email_policy_document" {
  statement {
    sid       = "AWSSESSendEmail"
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = ["noreply@${var.domain}"]
    }
  }
}

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "user" {
  name = "ses-user-${random_id.id.hex}"
  path = "/cloud-platform/${var.namespace}/"
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "${var.namespace}-ses-send-email"
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.ses_send_smtp_email_policy_document.json
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "kubernetes_secret" "ses_smtp_credentials" {
  metadata {
    name      = "ses-credentials"
    namespace = var.namespace
  }

  data = {
    aws_iam_access_key   = aws_iam_access_key.user.id
    ses_smtp_password_v4 = aws_iam_access_key.user.ses_smtp_password_v4
  }
}
