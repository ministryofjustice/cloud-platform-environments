data "aws_iam_policy_document" "dcs_S3_access" {

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

resource "aws_iam_policy" "dcs_S3_access_policy" {
  description = "cica_dcs_S3_access_policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.dcs_S3_access.json
}

data "aws_iam_policy_document" "app_service_S3_access" {

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

resource "aws_iam_policy" "app_service_S3_access_policy" {
  description = "cica_app_service_S3_access_policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.app_service_S3_access.json
}