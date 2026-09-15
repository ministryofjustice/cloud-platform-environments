# Grants the statsmisql instance in CFO's AWS account 
# read-only access to prod's backup bucket, so it can pull down
# backups directly via the AWS CLI/SDK

locals {
  statsmisql_principal_arn = "arn:aws:iam::035941410605:role/stats-mi_sql_IAM-Role"
}

resource "aws_s3_bucket_policy" "statsmisql_backup_bucket_policy" {
  bucket = module.sqlserver_backup_s3_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowStatsmisqlListBucket",
        Effect = "Allow",
        Principal = {
          AWS = local.statsmisql_principal_arn
        },
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = module.sqlserver_backup_s3_bucket.bucket_arn
      },
      {
        Sid    = "AllowStatsmisqlGetBackups",
        Effect = "Allow",
        Principal = {
          AWS = local.statsmisql_principal_arn
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectAttributes"
        ],
        Resource = "${module.sqlserver_backup_s3_bucket.bucket_arn}/*"
      }
    ]
  })
}
