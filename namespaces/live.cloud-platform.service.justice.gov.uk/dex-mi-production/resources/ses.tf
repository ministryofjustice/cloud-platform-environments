resource "aws_ses_domain_identity" "metabase_domain" {
  domain = "cdpt-metabase.service.justice.gov.uk"
}

resource "aws_ses_domain_identity_verification" "metabase_domain_identity" {
  domain     = aws_ses_domain_identity.metabase_domain.id
  depends_on = [aws_route53_record.metabase_domain_amazonses_verification_record]
}

resource "aws_ses_domain_dkim" "metabase_domain_dkim" {
  domain = aws_ses_domain_identity.metabase_domain.domain
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "metabase_smtp_user" {
  name = "metabase-smtp-user"
  path = "/system/ses-smtp-user/"
}

resource "aws_iam_access_key" ",metabase_smtp_user" {
  user = aws_iam_user.metabase_smtp_user.name
}

data "aws_iam_policy_document" "metabase_ses_sender" {
  statement {
    actions = ["ses:SendRawEmail"]
    resources = [
      "arn:aws:ses:eu-west-2:${data.aws_caller_identity.current.account_id}:identity/cdpt-metabase.cloud-platform.service.justice.gov.uk"
    ]
  }
}

resource "aws_iam_policy" "metabase_ses_sender" {
  name        = "metabase-ses-sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.metabase_ses_sender.json
}

resource "aws_iam_user_policy_attachment" "metabase_smtp_user_policy_attachment" {
  user       = aws_iam_user.metabase_smtp_user.name
  policy_arn = aws_iam_policy.metabase_ses_sender.arn
}

resource "kubernetes_secret" "metabase_smtp_user" {
    metadata {
        name      = "metabase-smtp-user"
        namespace = var.namespace
    }

    data = {
        smtp_username = aws_iam_access_key.metabase_smtp_user.id
        smtp_password = aws_iam_access_key.metabase_smtp_user.ses_smtp_password_v4
    }
}
