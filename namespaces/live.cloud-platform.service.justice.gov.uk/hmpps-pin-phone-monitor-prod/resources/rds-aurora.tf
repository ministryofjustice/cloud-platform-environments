module "rds_aurora" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=4.3.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Database configuration
  engine         = "aurora-postgresql"
  engine_version = "14.9"
  engine_mode    = "provisioned"
  instance_type  = "db.r6g.large"
  replica_count  = 2

  performance_insights_enabled = true
  allow_major_version_upgrade  = true
  auto_minor_version_upgrade   = true
  snapshot_identifier          = "arn:aws:rds:eu-west-2:754256621582:snapshot:hmpps-pin-phone-prod-pre-migration-20210730-1045"
  skip_setting_when_migrated   = true

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
