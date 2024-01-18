resource "random_id" "id" {
  byte_length = 8
}

module "dps_rds" {
  source                   = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                 = var.vpc_name
  team_name                = var.team_name
  business_unit            = var.business_unit
  application              = var.application
  is_production            = var.is_production
  namespace                = var.namespace
  db_engine_version        = "15.2"
  db_instance_class        = "db.t4g.small"
  db_max_allocated_storage = "10000" # maximum storage for autoscaling
  environment_name         = var.environment_name
  infrastructure_support   = var.infrastructure_support

  rds_family                = "postgres15"
  prepare_for_major_upgrade = false

}

data "aws_iam_policy_document" "manage_soc_cases_preprod_rds_to_s3_export_policy" {

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
      module.manage_soc_cases_rds_to_s3_bucket.bucket_arn,
      "${module.manage_soc_cases_rds_to_s3_bucket.bucket_arn}/*",
      "arn:aws:s3:::mojap-land/hmpps/manage_soc_cases/",
      "arn:aws:s3:::mojap-land/hmpps/manage_soc_cases/*"
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "manage_soc_cases-rds-to-s3-snapshots-user-${random_id.id.hex}"
  path = "/system/manage-soc-cases-rds-to-s3-snapshots-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "manage-soc-cases-rds-to-s3-snapshots-read-write"
  policy = data.aws_iam_policy_document.manage_soc_cases_preprod_rds_to_s3_export_policy.json
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
    namespace = "manage-soc-cases-prod"
  }

  data = {
    rds_instance_endpoint = module.dps_rds.rds_instance_endpoint
    database_name         = module.dps_rds.database_name
    database_username     = module.dps_rds.database_username
    database_password     = module.dps_rds.database_password
    rds_instance_address  = module.dps_rds.rds_instance_address
    url                   = "postgres://${module.dps_rds.database_username}:${module.dps_rds.database_password}@${module.dps_rds.rds_instance_endpoint}/${module.dps_rds.database_name}"
  }
}
