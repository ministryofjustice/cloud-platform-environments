module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=4.3.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "14.20"
  engine_mode    = "provisioned"
  instance_type  = "db.r6g.large"
  replica_count  = 2

  performance_insights_enabled = true
  allow_major_version_upgrade  = true
  auto_minor_version_upgrade   = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pcms_rds_aurora" {
  metadata {
    name      = "pcms-rds-aurora-output"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint        = module.rds_aurora.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.rds_aurora.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.rds_aurora.db_cluster_identifier
    database_name               = module.rds_aurora.database_name
    database_username           = module.rds_aurora.database_username
    database_password           = module.rds_aurora.database_password
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "dps-rds-instance-output-preprod"
    namespace = "hmpps-pin=phone-monitor-prod"
  }

  data = {
    database_name         = module.rds_aurora.database_name
    database_username     = module.rds_aurora.database_username
    database_password     = module.rds_aurora.database_password
    rds_instance_address  = module.rds_aurora.rds_cluster_reader_endpoint
  }
}