data "aws_iam_policy_document" "migration_policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    effect = "Allow"

    resources = [
      module.s3_bucket.bucket_arn,
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-mis-dev-alfresco-storage-s3bucket",
    ]
  }
  statement {
    actions = [
      "s3:*"
    ]

    effect = "Allow"

    resources = [
      "${module.s3_bucket.bucket_arn}/*",
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-mis-dev-alfresco-storage-s3bucket/*",
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
      "arn:aws:kms:eu-west-2:479759138745:key/990df68f-49b4-425c-a821-55faf729bf7d",
      "arn:aws:kms:eu-west-2:754256621582:key/26ec2090-94bf-49ae-a272-fc956b6a129a"
    ]
  }
  statement {
    actions   = ["rds:DescribeDBSnapshots", "rds:CopyDBSnapshot"]
    resources = ["arn:aws:rds:eu-west-2:479759138745:snapshot:alf-from-dev-to-cp"]
  }
}

resource "aws_iam_policy" "migration_policy" {
  name        = "bucket_migration_policy"
  description = "Policy to allow migration to cloud platform"
  policy      = data.aws_iam_policy_document.migration_policy.json
}
