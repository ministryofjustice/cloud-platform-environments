data "aws_iam_policy_document" "grafana_platform" {
  statement {
    sid       = "AWSSESSendEmail"
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = ["noreply@grafana.platform.${var.domain}"]
    }
  }
}

resource "aws_iam_user" "grafana_platform" {
  name = "hmpps-ems-prod-grafana-platform"
  path = "/cloud-platform/hmpps-ems-prod/"
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "aws_iam_user_policy" "grafana_platform" {
  name   = "hmpps-ems-prod-grafana-platform"
  user   = aws_iam_user.grafana_platform.name
  policy = data.aws_iam_policy_document.grafana_platform.json
}

resource "aws_iam_access_key" "grafana_platform" {
  user = aws_iam_user.grafana_platform.name
}

resource "kubernetes_secret" "grafana_platform_iam" {
  metadata {
    name      = "moj-cloud-platform-iam-grafana-platform"
    namespace = var.namespace
  }

  data = {
    aws_iam_access_key   = aws_iam_access_key.grafana_platform.id
    ses_smtp_password_v4 = aws_iam_access_key.grafana_platform.ses_smtp_password_v4
  }
}