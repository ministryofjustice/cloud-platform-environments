data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    sid = "AllowS3ObjectOperations"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      module.dependencytrack_backup_s3_bucket.bucket_arn,
      "${module.dependencytrack_backup_s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_access" {
  name   = "s3-access-policy"
  role   = module.irsa.role_name
  policy = data.aws_iam_policy_document.s3_access_policy.json
}
