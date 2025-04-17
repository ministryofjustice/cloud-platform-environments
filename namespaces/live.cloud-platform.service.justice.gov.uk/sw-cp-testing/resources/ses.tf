data "aws_caller_identity" "current" {}

resource "aws_iam_user" "sw_smtp_user" {
  name = "sw-smtp-user"
  path = "/system/ses-smtp-user/"
}

resource "aws_iam_access_key" "sw_smtp_user" {
  user = aws_iam_user.sw_smtp_user.name
}

data "aws_iam_policy_document" "sw_ses_sender" {
  statement {
    actions = ["ses:SendRawEmail"]
    resources = [
      "arn:aws:ses:eu-west-2:${data.aws_caller_identity.current.account_id}:identity/ext-dns-test.cloud-platform.service.justice.gov.uk"
    ]
  }
}

resource "aws_iam_policy" "sw_ses_sender" {
  name        = "sw-ses-sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.sw_ses_sender.json
}

resource "aws_iam_user_policy_attachment" "sw_smtp_user_policy_attachment" {
  user       = aws_iam_user.sw_smtp_user.name
  policy_arn = aws_iam_policy.sw_ses_sender.arn
}

resource "kubernetes_secret" "sw_smtp_user" {
    metadata {
        name      = "sw-smtp-user"
        namespace = var.namespace
    }

    data = {
        smtp_username = aws_iam_access_key.sw_smtp_user.id
        smtp_password = aws_iam_access_key.sw_smtp_user.ses_smtp_password_v4
    }
}
