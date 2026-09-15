# These two grants together support a manual prod -> preprod refresh, where
# an operator identifies the latest backup in prod's bucket and then calls
# msdb.dbo.rds_restore_database with its S3 ARN.

# Grants the preprod RDS instance's backup/restore IAM role (defined in
# rds-mssql-backup-iam.tf) read-only access to prod's backup bucket, so a
# prod backup can be restored into preprod. This is intentionally read-only
# (no Put/Delete/Abort) - preprod must never be able to write to prod's
# bucket. This role is only ever assumed internally by RDS itself when
# servicing the rds_restore_database procedure call.
resource "aws_iam_role_policy" "sqlserver_restore_from_prod_s3_iam_role_policy" {
  name = "${var.namespace}-mssql-restore-from-prod-policy"
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
        Resource = "arn:aws:s3:::hmpps-cfo-case-assessment-tracking-system-backup-production"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectAttributes",
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::hmpps-cfo-case-assessment-tracking-system-backup-production/*"
      }
    ]
  })
}

# Allows preprod's IRSA-bound service account to list (but not read) objects
# in prod's SQL Server backup bucket, so an operator performing the restore
# can identify the latest backup file before calling
# msdb.dbo.rds_restore_database with its S3 ARN. Retrieving the object itself
# is only ever done by RDS via the mssql-backup IAM role above - this policy
# is list-only and grants no s3:GetObject access.
resource "aws_iam_policy" "list_prod_backup_bucket" {
  name        = "${var.namespace}-list-prod-backup-bucket"
  description = "Allows listing (not reading) objects in prod's SQL Server backup bucket to identify the latest backup for a preprod restore"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::hmpps-cfo-case-assessment-tracking-system-backup-production"
      }
    ]
  })
}
