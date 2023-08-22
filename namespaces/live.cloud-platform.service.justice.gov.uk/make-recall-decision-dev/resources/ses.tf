module "ses_irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = {
    ses = aws_iam_policy.ses_policy.arn
  }
  service_account_name  = "${var.namespace}-ses"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "ses_policy" {
  name   = "${var.namespace}-ses-policy"
  policy = data.aws_iam_policy_document.ses_send_email_policy_document.json
}

data "aws_iam_policy_document" "ses_send_email_policy_document" {
  statement {
    sid       = "AWSSESSendEmail"
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = ["noreply@consider-a-recall-dev.hmpps.service.justice.gov.uk"]
    }
  }
}
