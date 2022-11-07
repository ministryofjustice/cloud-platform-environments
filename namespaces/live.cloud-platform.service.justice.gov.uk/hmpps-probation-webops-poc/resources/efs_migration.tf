data "aws_iam_policy_document" "efs_migration_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${module.s3_bucket.bucket_arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::356676313489:role/vcms-dev-efs-migration"]
    }
  }
}

resource "aws_iam_role" "efs_migration_role" {
  name = "efs_migration_role"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.efs_migration_policy.json
}

resource "aws_iam_policy_attachment" "efs_migration_attachment" {
  name       = "efs_migration_attachment"
  roles      = [aws_iam_role.efs_migration_role.name]
  policy_arn = aws_iam_policy.efs_migration_policy.arn
}
