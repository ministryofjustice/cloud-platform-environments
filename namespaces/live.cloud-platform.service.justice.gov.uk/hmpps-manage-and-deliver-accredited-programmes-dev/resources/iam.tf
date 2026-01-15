resource "aws_iam_role" "sqlserver_backup_s3_iam_role" {
  name = "sqlserver-backup-s3-iam-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sqlserver_backup_s3_iam_role_policy" {
  name = "sqlserver-backup-s3-iam-role-policy"
  role = aws_iam_role.sqlserver_backup_s3_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = module.sqlserver_backup_s3_bucket.bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = "${module.sqlserver_backup_s3_bucket.bucket_arn}/*"
      }
    ]
  })
}
