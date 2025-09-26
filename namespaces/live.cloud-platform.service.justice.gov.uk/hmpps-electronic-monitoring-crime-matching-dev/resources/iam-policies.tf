data "aws_iam_policy_document" "ssm_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:754256621582:parameter/${var.namespace}/athena_general_role_arn"
    ]
  }
}

resource "aws_iam_policy" "ssm_access" {
  name   = "${var.namespace}-ssm-policy"
  policy = data.aws_iam_policy_document.ssm_policy.json
  tags = local.tags
}

data "aws_iam_policy_document" "athena_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      data.aws_ssm_parameter.athena_general_role_arn.value
    ]
  }
}

resource "aws_iam_policy" "athena_access" {
  name   = "${var.namespace}-athena-policy-general"
  policy = data.aws_iam_policy_document.athena_policy.json
  tags = local.tags
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ses_s3_access" {
  statement {
    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.s3_email_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [
        "arn:aws:ses:eu-west-2:${data.aws_caller_identity.current.account_id}::receipt-rule/${aws_ses_receipt_rule.store_email.name}"
      ]
    }
  }
}

# Attach policy
resource "aws_s3_bucket_policy" "s3_email_bucket" {
  bucket = aws_s3_bucket.s3_email_bucket.id
  policy = data.aws_iam_policy_document.ses_s3_access.json
}
