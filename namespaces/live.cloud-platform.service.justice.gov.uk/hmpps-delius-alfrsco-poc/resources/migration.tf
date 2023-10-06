data "aws_iam_policy_document" "migration_policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    effect = "Allow"

    resources = [
      module.s3_bucket.bucket_arn,
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-core-dev-alfresco-storage-s3bucket",
    ]
  }
  statement {
    actions = [
      "s3:*"
    ]

    effect = "Allow"

    resources = [
      "${module.s3_bucket.bucket_arn}/*",
      "arn:aws:s3:::tf-eu-west-2-hmpps-delius-core-dev-alfresco-storage-s3bucket/*",
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
    resources = ["arn:aws:kms:eu-west-2:563502482979:key/cc27c83f-1935-43f8-9867-18018652fd8f", "arn:aws:kms:eu-west-2:563502482979:key/46259325-87eb-42d3-8b28-7ff49e944ac5", "arn:aws:kms:eu-west-2:754256621582:key/26ec2090-94bf-49ae-a272-fc956b6a129a",
    "arn:aws:kms:eu-west-2:723123699647:key/be532f03-c0b0-4306-8ce0-26fc906b6b08"]
  }
  statement {
    actions   = ["rds:DescribeDBSnapshots", "rds:CopyDBSnapshot"]
    resources = ["arn:aws:rds:eu-west-2:563502482979:snapshot:to-cloud-platform", "arn:aws:rds:eu-west-2:754256621582:snapshot:alf-from-dev-to-cp"]
  }
}

resource "aws_iam_policy" "migration_policy" {
  name        = "bucket_migration_policy"
  description = "Policy to allow migration to cloud platform"
  policy      = data.aws_iam_policy_document.migration_policy.json
}
