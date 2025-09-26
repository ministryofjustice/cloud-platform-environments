# S3 Bucket for email storage
resource "aws_s3_bucket" "s3_email_bucket" {
  bucket = var.email_bucket_name
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ses_s3_access" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

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
        "arn:aws:ses:eu-west-2:${data.aws_caller_identity.current.account_id}::receipt-rule-set/${aws_ses_receipt_rule_set.main.rule_set_name}"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_email_bucket" {
  bucket = aws_s3_bucket.s3_email_bucket.id
  policy = data.aws_iam_policy_document.ses_s3_access.json
}