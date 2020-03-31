data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

resource "random_id" "id" {
  byte_length = 8
}

module "dps_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.3"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  db_engine_version      = "11.4"
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  force_ssl              = "true"
  rds_family             = "postgres11"

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "pathfinder_dev_rds_to_s3_policy_document" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["export.rds.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "pathfinder_dev_rds_to_s3_policy" {
  statement {
    sid = "AllowRdsToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid = "AllowRdsToWriteSnapshottoS3"
    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "${module.pathfinder_analytics_s3_bucket.bucket_arn}",
      "${module.pathfinder_analytics_s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role" "pathfinder_dev_rds_to_s3_role" {
  name               = "pathfinder-dev-rds-to-s3-iam-role-${random_id.id.hex}"
  description        = "IAM role for pathfinder-dev rds to s3 export"
  assume_role_policy = data.aws_iam_policy_document.pathfinder_dev_rds_to_s3_policy_document.json
}

resource "aws_iam_policy" "pathfinder_rds_to_s3_policy" {
  name   = "pathfinder_rds_to_s3_policy"
  policy = data.aws_iam_policy_document.pathfinder_dev_rds_to_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "pathfinder_rds_to_s3_policy_attach" {
  role       = aws_iam_role.pathfinder_dev_rds_to_s3_role.name
  policy_arn = aws_iam_policy.pathfinder_rds_to_s3_policy.arn
}

resource "aws_kms_key" "pathfinder_rds_to_s3_export_key" {
  description = "Pathfinder RDS TO S3 Export Key"
  provider    = aws.ireland
}

data "aws_iam_policy_document" "pathfinder_dev_rds_to_s3_export_policy" {

  statement {
    actions = [
      "iam:PassRole",
      "rds:StartExportTask",
      "rds:CancelExportTask",
      "rds:DescribeExportTasks"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "rds:DescribeDBSnapshots",
      "rds:DescribeDBInstances"
    ]

    resources = [
      "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:db:${element(split(".", module.dps_rds.rds_instance_endpoint), 0)}"
    ]
  }

  statement {
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.pathfinder_rds_to_s3_export_key.key_id}"
    ]
  }

  statement {
    sid = "AllowRdsToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid = "AllowRdsToWriteSnapshottoS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "${module.pathfinder_analytics_s3_bucket.bucket_arn}",
      "${module.pathfinder_analytics_s3_bucket.bucket_arn}/*",
      "${module.pathfinder_reporting_s3_bucket.bucket_arn}",
      "${module.pathfinder_reporting_s3_bucket.bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "rds:CopyDBSnapshot",
      "rds:DeleteDBSnapshot"
    ]

    resources = [
      "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:snapshot:*"
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "pathfinder-rds-to-s3-snapshots-user-${random_id.id.hex}"
  path = "/system/pathfinder-rds-to-s3-snapshots-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "pathfinder-rds-to-s3-snapshots-read-write"
  policy = data.aws_iam_policy_document.pathfinder_dev_rds_to_s3_export_policy.json
  user   = aws_iam_user.user.name
}


resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "dps-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint       = module.dps_rds.rds_instance_endpoint
    database_name               = module.dps_rds.database_name
    database_username           = module.dps_rds.database_username
    database_password           = module.dps_rds.database_password
    rds_instance_address        = module.dps_rds.rds_instance_address
    access_key_id               = module.dps_rds.access_key_id
    secret_access_key           = module.dps_rds.secret_access_key
    url                         = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
    rds_to_s3_user_arn          = aws_iam_user.user.arn
    rds_to_s3_access_key_id     = aws_iam_access_key.user.id
    rds_to_s3_secret_access_key = aws_iam_access_key.user.secret
    rds_to_s3_cmk_key_id        = aws_kms_key.pathfinder_rds_to_s3_export_key.key_id
  }
}

