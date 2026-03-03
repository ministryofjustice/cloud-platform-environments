module "upload_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
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
            # The following role was provided by NEC, but has since caused 
            # deployment issues.  Commenting out while NEC investigate.
            # --TJWC 2026-02-24 --RW 2026-03-02
            #"arn:aws:iam::778742069978:role/im-preprod-s3-datasync",
            "arn:aws:iam::778742069978:role/im-production-s3-datasync"
          ]
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
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
          "s3:GetObject"
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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

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
