data "aws_kms_alias" "rds" {
  name = "alias/cloud-platform-d719359696236437"
}

resource "aws_db_snapshot_copy" "cis_rds_shared_snapshot_copy" {
  source_db_snapshot_identifier = "arn:aws:rds:eu-west-2:185926004630:snapshot:cis-22042026-encrypted-with-new-kms"
  target_db_snapshot_identifier = "cis-rds-20260925"
  kms_key_id                    = data.aws_kms_alias.rds.target_key_arn
}

module "rds_instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine                = "oracle-se2"
  db_engine_version        = "19"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.m5.xlarge"
  db_allocated_storage     = "1000"
  db_iops                  = "12000"
  rds_name                 = "cis-rds"
  db_name                  = "CIS"
  license_model            = "license-included"
  snapshot_identifier      = aws_db_snapshot_copy.cis_rds_shared_snapshot_copy.id
  opt_in_xsiam_logging     = true

  # Avoid default parameters set by MOJ
  db_parameter = []

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "cis-rds-details"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_instance.rds_instance_endpoint
    database_name         = module.rds_instance.database_name
    database_username     = module.rds_instance.database_username
    database_password     = module.rds_instance.database_password
    database_address      = module.rds_instance.rds_instance_address
    database_port         = module.rds_instance.rds_instance_port
  }
}