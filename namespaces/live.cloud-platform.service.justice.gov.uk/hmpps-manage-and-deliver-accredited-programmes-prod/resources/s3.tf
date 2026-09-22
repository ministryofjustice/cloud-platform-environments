# Existing S3 bucket — kept as-is, do not modify.
module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire files after 30 days"

      expiration = [
        {
          days = 30
        },
      ]
    },
  ]

}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "im-backup-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

# New dedicated S3 bucket for SQL Server backup/restore pipeline.
# Separate from the existing s3_bucket to avoid any disruption.
# APG-2664: the 14-day lifecycle rule was removed 2026-09-10. This bucket is
# no longer actively written to (cronjob-s3-transfer is suspended) so no new
# files will accumulate. Contents currently empty; kept to avoid disturbing
# the module state until PR 3 removes it entirely.
module "sqlserver_backup_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  # APG-2664: lifecycle rule removed. Bucket is no longer written to.
  lifecycle_rule = []

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

# Upload bucket — NEC DataSync will push .bak files here (once their prod role is created).
# The s3-transfer CronJob copies from here to the backup bucket, then deletes.
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
  bucket     = module.upload_s3_bucket.bucket_name
  depends_on = [module.irsa-cronjob]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            module.irsa-cronjob.role_arn,
            # NEC DataSync role — uncomment once NEC confirm prod should receive files directly.
            # This is the same role currently active in preprod's upload bucket policy.
            # "arn:aws:iam::778742069978:role/im-production-s3-datasync"
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

# =============================================================================
# APG-2664 — Archive bucket for final NEC .bak file(s), forever.
#
# Created 2026-09-10 as part of NEC pipeline decommission. Purpose: preserve
# the final NEC SQL Server backup (backup-production-IM-dbo-only-20260909013009.bak,
# ingested Thu 10 Sep 2026) forever, alongside the RDS manual snapshot
# hmpps-acp-prod-nec-final-20260910095751.
#
# Protection layers (F1, F7, F8, F15, F16, F26):
#   1. Versioning enabled — resists overwrite/delete via object version restore.
#   2. Bucket policy denies s3:DeleteObject*, s3:DeleteObjectVersion*,
#      s3:DeleteBucket, s3:DeleteBucketPolicy on Principal "*" — no IAM role
#      or user in this account (including irsa-sqlserver) can delete objects
#      or the bucket, nor wipe the deny policy. AWS account root retains the
#      ability to change the bucket policy (documented AWS behaviour, F26) —
#      this is not attempted-attack resistant, it is *operational-mistake*
#      resistant.
#   3. Bucket-policy MUTATION (PutBucketPolicy/PutLifecycleConfiguration/
#      PutBucketVersioning) is intentionally NOT denied — those flow via
#      normal Terraform PRs under Cloud Platform review, which is the actual
#      change gate. Denying them would make this a one-way trip and block
#      legitimate future ops (e.g. Glacier transition per D17).
#   4. No lifecycle rule — objects remain in S3 Standard indefinitely (D2, D17).
#   5. prevent_destroy = true on the kubernetes_secret below acts as a Terraform
#      tripwire against accidental module removal.
#
# Deletion requires a Terraform PR that relaxes the bucket policy first, then
# a separate PR that removes the module. No break-glass exemption (D8, F16).
#
# The shared s3-bucket module hardcodes force_destroy = "true" (F1) so this
# module block MUST NEVER be removed while the archive holds data.
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
  # A ~32 GB .bak costs ~$0.74/month at Standard. Future phased optimisation
  # to GLACIER_IR is documented in D17 but deliberately deferred.
  lifecycle_rule = []

  # Deny-delete bucket policy (D8, F1, F16). Blanket deny with no break-glass
  # exemption — deletion requires a Terraform PR to relax this policy first.
  # $${bucket_arn} is the templating token used by the shared module's
  # replace() call (verified in module source main.tf line 50).
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
# reviewer before any destructive action. A determined commit that removes
# BOTH this secret block and the module block simultaneously will bypass the
# tripwire; the deny bucket policy above is the ultimate defence.
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
