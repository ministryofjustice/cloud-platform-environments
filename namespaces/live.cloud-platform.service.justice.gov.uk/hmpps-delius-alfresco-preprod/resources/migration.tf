data "aws_iam_policy_document" "migration_policy" {
  statement {
    actions = [
      # Bucket level permissions
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions",

      # object level permissions to read from source
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
    ]

    effect = "Allow"

    resources = [
      module.s3_bucket.bucket_arn,
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-pre-prod-alfresco-storage-s3bucket",
    ]
  }
  statement {
    actions = [
      "s3:*"
    ]

    effect = "Allow"

    resources = [
      "${module.s3_bucket.bucket_arn}/*",
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-pre-prod-alfresco-storage-s3bucket/*",
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
      "arn:aws:kms:eu-west-2:010587221707:key/0c35d7a8-b6d3-44e7-9a21-a2fede552773"
    ]
  }
}

resource "aws_iam_policy" "migration_policy" {
  name        = "${var.namespace}-bucket_migration_policy"
  description = "Policy to allow migration to cloud platform"
  policy      = data.aws_iam_policy_document.migration_policy.json
}
