resource "aws_iam_role" "sqlserver_backup_s3_iam_role" {
  name = "hmpps-acp-${var.environment}-sqlserver-backup-s3-iam-role"
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
  name = "hmpps-acp-${var.environment}-sqlserver-backup-s3-iam-role-policy"
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
        Resource = [
          module.sqlserver_backup_s3_bucket.bucket_arn,
          # Preprod backup bucket — allows RDS to restore directly from preprod .bak files
          var.preprod_backup_bucket_arn
        ]
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
      },
      {
        # Read-only access to preprod bucket (no write needed)
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${var.preprod_backup_bucket_arn}/*"
      }
    ]
  })
}

# IAM policy for the irsa-sqlserver service account to read preprod's backup bucket.
# This allows the find-backup-file init container to list/discover .bak files in preprod.
resource "aws_iam_policy" "preprod_backup_s3_read" {
  name = "hmpps-acp-${var.environment}-preprod-backup-s3-read"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = var.preprod_backup_bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${var.preprod_backup_bucket_arn}/*"
      }
    ]
  })
}

