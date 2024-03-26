data "aws_iam_policy_document" "migration_policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    effect = "Allow"

    resources = [
      module.s3_bucket.bucket_arn,
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-stage-alfresco-storage-s3bucket",
    ]
  }
  statement {
    actions = [
      "s3:*"
    ]

    effect = "Allow"

    resources = [
      "${module.s3_bucket.bucket_arn}/*",
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-stage-alfresco-storage-s3bucket/*",
    ]
  }
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:kms:eu-west-2:728765553488:key/3971f921-c434-42e8-887c-920ffc6b56c9"
    ]
  }
}

resource "aws_iam_policy" "migration_policy" {
  name        = "${var.namespace}-bucket_migration_policy"
  description = "Policy to allow migration to cloud platform"
  policy      = data.aws_iam_policy_document.migration_policy.json
}
