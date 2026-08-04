resource "aws_iam_role" "sqlserver_backup_s3_iam_role" {
  name = "${var.namespace}-mssql-backup"
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

resource "aws_kms_key" "sqlserver_backup" {
  description             = "${var.namespace} SQL Server native backup/restore encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name                   = "${var.namespace}-mssql-backup"
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
    team-name              = var.team_name
  }
}

resource "aws_kms_alias" "sqlserver_backup" {
  name          = "alias/${var.namespace}-mssql-backup"
  target_key_id = aws_kms_key.sqlserver_backup.key_id
}

resource "aws_iam_role_policy" "sqlserver_backup_s3_iam_role_policy" {
  name = "${var.namespace}-mssql-backup-policy"
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
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = aws_kms_key.sqlserver_backup.arn
      }
    ]
  })
}
