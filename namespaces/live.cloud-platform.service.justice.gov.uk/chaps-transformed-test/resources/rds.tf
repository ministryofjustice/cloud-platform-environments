/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
*/
module "rds_mssql" {
  source       = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  storage_type = "gp3"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "100"
  enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2025-11-10" # Uncomment to rotate your database password.

  # SQL Server specifics
  db_engine            = "sqlserver-web"
  db_engine_version    = "14.00.3381.3.v1"
  rds_family           = "sqlserver-web-14.0"
  db_instance_class    = "db.t3.2xlarge"
  db_allocated_storage = 32 # minimum of 20GiB for SQL Server
  option_group_name    = aws_db_option_group.sqlserver_backup_restore.name

  # Some engines can't apply some parameters without a reboot(ex SQL Server cant apply force_ssl immediate).
  # You will need to specify "pending-reboot" here, as default is set to "immediate".
  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    }

  ]

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  enable_irsa = true
}

resource "kubernetes_secret" "rds_mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_username = module.rds_mssql.database_username
    database_password = module.rds_mssql.database_password
  }
}

resource "kubernetes_config_map" "rds_mssql" {
  metadata {
    name      = "rds-mssql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_mssql.rds_instance_endpoint
    rds_instance_address  = module.rds_mssql.rds_instance_address
  }
}

resource "aws_db_option_group" "sqlserver_backup_restore" {
  name                 = "${var.namespace}-sqlserver-14-backup-restore"
  engine_name          = "sqlserver-web"
  major_engine_version = "14.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"
    option_settings {
      name = "IAM_ROLE_ARN"
      value  = aws_iam_role.rds_s3_backup_restore.arn
    }
  }
}

variable "backup_bucket" { 
  type = string 
  default = "tp-dbbackups"
  description = "S3 bucket that stores SQL Server .bak files" 
}        

variable "backup_prefix" { 
  type = string 
  default = "chaps-dev/"
  description = "Key prefix within the backup bucket" 
} 

resource "aws_iam_role" "rds_s3_backup_restore" {
  name = "${var.namespace}-rds-s3-backup-restore"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "rds.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

# Least-privilege inline policy: list bucket + R/W objects in the prefix
resource "aws_iam_role_policy" "rds_s3_backup_restore" {
  name = "${var.namespace}-rds-s3-backup-restore"
  role = aws_iam_role.rds_s3_backup_restore.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "ListBucket",
        Effect: "Allow",
        Action: ["s3:ListBucket"],
        Resource: "arn:aws:s3:::${var.backup_bucket}",
        Condition: {
          StringLike: { "s3:prefix": ["${var.backup_prefix}*", "${var.backup_prefix}"] }
        }
      },
      {
        Sid: "RWPrefix",
        Effect: "Allow",
        Action: ["s3:GetObject","s3:PutObject","s3:DeleteObject"],
        Resource: "arn:aws:s3:::${var.backup_bucket}/${var.backup_prefix}*"
      }
    ]
  })
}


data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid     = "AllowRDSRole"
    effect  = "Allow"
    principals = { 
      type = "AWS"
      identifiers = [aws_iam_role.rds_s3_backup_restore.arn] 
    }
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.backup_bucket}"]
  }
  statement {
    sid     = "AllowRDSRoleObjects"
    effect  = "Allow"
    principals { type = "AWS", identifiers = [aws_iam_role.rds_s3_backup_restore.arn] }
    actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.backup_bucket}/${var.backup_prefix}*"]
  }
}

resource "aws_s3_bucket_policy" "backup_bucket" {
  bucket = var.backup_bucket
  policy = data.aws_iam_policy_document.bucket_policy.json
}
