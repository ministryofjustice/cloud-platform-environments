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

data "aws_iam_policy_document" "pathfinder_dev_rds_to_s3_export_policy" {

  statement {
    sid = "AllowRdsExportUserToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid = "AllowRdsExportUserWriteToS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "${module.pathfinder_rds_to_s3_bucket.bucket_arn}",
      "${module.pathfinder_rds_to_s3_bucket.bucket_arn}/*",
      "arn:aws:s3:::mojap-land/hmpps/pathfinder/",
      "arn:aws:s3:::mojap-land/hmpps/pathfinder/*"
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
    url                         = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
    rds_to_s3_user_arn          = aws_iam_user.user.arn
    rds_to_s3_access_key_id     = aws_iam_access_key.user.id
    rds_to_s3_secret_access_key = aws_iam_access_key.user.secret
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "dps-rds-instance-output-preprod"
    namespace = "pathfinder-prod"
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    access_key_id         = module.dps_rds.access_key_id
    secret_access_key     = module.dps_rds.secret_access_key
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}
