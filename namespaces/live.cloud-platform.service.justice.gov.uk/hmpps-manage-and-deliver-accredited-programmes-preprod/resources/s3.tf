module "upload_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  logging_enabled        = var.logging_enabled
  log_target_bucket      = module.s3_upload_logging_bucket.bucket_name
  log_path               = var.log_path
  namespace              = var.namespace

  # Safety net: auto-delete files after 30 days if the cronjob fails to remove them.
  # Normal operation removes files within hours; this prevents runaway accumulation
  # (e.g. the 1.47TB incident of Apr 29 2026 caused by weeks of missed deletions).
  lifecycle_rule = [
    {
      id      = "expire-stale-uploads"
      enabled = true
      expiration = [
        {
          days = 30
        }
      ]
    }
  ]

  providers = {
    aws = aws.london
  }
}

resource "aws_s3_bucket_policy" "upload_s3_bucket_policy" {
  bucket = module.upload_s3_bucket.bucket_name
  depends_on = [module.irsa-cronjob]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            module.irsa-cronjob.role_arn,
            # APG-2664 (2026-09-11): NEC's prod DataSync role REVOKED — pipeline decommissioned.
            # The final .bak (backup-production-IM-dbo-only-20260908013109.bak) is preserved
            # forever in the prod archive bucket. This removal is the actual access revocation.
            # Historical (pre-existing): NEC preprod datasync role — commented out as the IAM role
            # never existed in AWS account 778742069978. Do NOT re-enable.
            #"arn:aws:iam::778742069978:role/im-preprod-s3-datasync",
            #"arn:aws:iam::778742069978:role/im-production-s3-datasync",
          ]
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:GetObjectAcl",
          "s3:GetObjectVersion",
          "s3:GetObjectTagging",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
        ]
        Resource = [
          module.upload_s3_bucket.bucket_arn,
          "${module.upload_s3_bucket.bucket_arn}/*"
        ]
      },
    ]
  })
}

resource "kubernetes_secret" "upload_s3_bucket" {
  metadata {
    name      = "upload-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.upload_s3_bucket.bucket_arn
    bucket_name = module.upload_s3_bucket.bucket_name
  }
}

module "s3_upload_logging_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ServerAccessLogsPolicy",
        Effect = "Allow",
        Principal = {
          Service = "logging.s3.amazonaws.com"
        },
        Action = [
          "s3:PutObject"
        ],
        Resource = "$${bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            module.irsa-cronjob.role_arn
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "kubernetes_secret" "s3_upload_logging_bucket" {
  metadata {
    name      = "s3-logging-bucket-output"
    namespace = var.namespace
  }

  data = {
    BUCKET_ARN  = module.s3_upload_logging_bucket.bucket_arn
    BUCKET_NAME = module.s3_upload_logging_bucket.bucket_name
  }
}

module "sqlserver_backup_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # APG-2664 (2026-09-11): 14-day lifecycle rule REMOVED — NEC pipeline decommissioned.
  # The DB restore CronJob (db-restore-cronjob) that consumed the "latest" file is suspended,
  # so there is no longer a moving "latest" to point at. The final .bak
  # (backup-production-IM-dbo-only-20260908013109.bak) is already preserved forever in the
  # prod archive bucket cloud-platform-237c423a923efb55500dc5fd4dda2ff4. Historical .bak files
  # (~170 files, ~5.4 TB) are retained by explicit product decision for forensic/audit purposes.
  # Deleting the bucket is out of scope for APG-2664.

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "sqlserver_backup_s3_bucket" {
  metadata {
    name      = "sqlserver-backup-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.sqlserver_backup_s3_bucket.bucket_arn
    bucket_name = module.sqlserver_backup_s3_bucket.bucket_name
  }
}

# Allow prod namespace roles to read .bak files from this bucket.
# Prod's RDS IAM role uses rds_restore_database to pull directly from S3.
# Prod's IRSA role (irsa-sqlserver) lists/discovers the latest .bak file.
resource "aws_s3_bucket_policy" "sqlserver_backup_allow_prod_read" {
  bucket = module.sqlserver_backup_s3_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowProdRDSAndIRSARead",
        Effect = "Allow",
        Principal = {
          AWS = [
            # Prod RDS IAM role (used by rds_restore_database)
            var.prod_rds_iam_role_arn,
            # Prod IRSA role (used by irsa-sqlserver service account)
            var.prod_irsa_sqlserver_role_arn
          ]
        },
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          module.sqlserver_backup_s3_bucket.bucket_arn,
          "${module.sqlserver_backup_s3_bucket.bucket_arn}/*"
        ]
      }
    ]
  })
}

# =============================================================================
# APG-2664: Archive bucket for permanent preservation of the final NEC .bak.
# This bucket receives the final backup-production-IM-dbo-only-20260908013109.bak
# (~32.5 GiB) via a post-merge `aws s3 cp` runbook step from the newly-live
# sqlserver_rds_service_pod. Deny-delete bucket policy makes deletion require
# a Terraform PR to relax this policy first. Matches the prod archive pattern
# (PR #45463 merged 2026-09-11).
# =============================================================================
module "archive_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  versioning = true

  # No lifecycle rule — objects stay in S3 Standard forever (D2).
  # A ~32 GB .bak costs ~$0.74/month at Standard.
  lifecycle_rule = []

  # Deny-delete bucket policy (D8, F1, F16). Blanket deny with no break-glass
  # exemption — deletion requires a Terraform PR to relax this policy first.
  # $${bucket_arn} is the templating token used by the shared module's
  # replace() call (verified in module source main.tf line 54).
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "APG2664DenyDelete"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectTagging",
          "s3:DeleteObjectVersion",
          "s3:DeleteObjectVersionTagging",
          "s3:DeleteBucket",
          "s3:DeleteBucketPolicy"
        ]
        Resource = [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      }
    ]
  })

  providers = {
    aws = aws.london
  }
}

# The prevent_destroy on this secret is a Terraform tripwire (F24). If the
# archive module block is removed from .tf, this secret's data-source references
# become undefined and plan errors out at reference-resolution — nudging the
# reviewer before any destructive action. The deny bucket policy above is the
# ultimate defence.
resource "kubernetes_secret" "archive_s3_bucket" {
  metadata {
    name      = "archive-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.archive_s3_bucket.bucket_arn
    bucket_name = module.archive_s3_bucket.bucket_name
  }

  lifecycle {
    prevent_destroy = true
  }
}
