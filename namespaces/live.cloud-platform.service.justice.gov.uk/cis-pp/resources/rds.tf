resource "aws_db_snapshot_copy" "cis_rds_shared_snapshot_copy" {
  source_db_snapshot_identifier = "arn:aws:rds:eu-west-2:185926004630:snapshot:cis-22042026-encrypted-with-new-kms"
  target_db_snapshot_identifier = "cis-rds-20260925"

  lifecycle {
    ignore_changes = [kms_key_id]
  }
}

resource "aws_db_snapshot_copy" "cis_rds_shared_snapshot_new_kms" {
  source_db_snapshot_identifier = "cis-rds-20260925"
  target_db_snapshot_identifier = "cis-rds-20261125"
  kms_key_id                    = aws_kms_alias.rds.target_key_arn
}

resource "aws_kms_key" "rds" {
  description = "${var.namespace}-rds"

  tags = var.tags
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.namespace}-rds"
  target_key_id = aws_kms_key.rds.key_id
}
module "rds_instance" {
  source = "github.com/ministryofjustice/cis-cloud-platform-terraform-rds-instance?ref=decfdf1b2c7562318ec2dbaee858fde884e888a4"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  db_engine            = "oracle-se2"
  db_engine_version    = "19"
  rds_family           = "oracle-se2-19"
  db_instance_class    = "db.m5.xlarge"
  db_allocated_storage = "1000"
  db_iops              = 12000
  rds_name             = "cis-rds"
  db_name              = "CIS"
  license_model        = "license-included"
  snapshot_identifier  = aws_db_snapshot_copy.cis_rds_shared_snapshot_new_kms.id
  opt_in_xsiam_logging = true
  skip_final_snapshot  = true
  kms_key_id           = aws_kms_key.rds.arn

  # Avoid default parameters set by MOJ
  db_parameter = [{
    "apply_method" : "immediate",
    "name" : "max_string_size",
    "value" : "EXTENDED"
  }]

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
    database_username     = "CRA_SYSTEM_USER" # The username for the system user - created post-snapshot restoration - must be re-created if restored again.
    database_password     = module.rds_instance.database_password
    database_address      = module.rds_instance.rds_instance_address
    database_port         = module.rds_instance.rds_instance_port
  }
}