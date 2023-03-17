# Generic RDS Aurora
module "aurora_db" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=2.1.0"

  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business-unit                = var.business_unit
  application                  = var.application
  is-production                = var.is_production
  namespace                    = var.namespace
  environment-name             = var.environment-name
  infrastructure-support       = var.infrastructure_support

  engine         = "aurora-postgresql"
  engine_version = "14.6"
  engine_mode    = "provisioned"

  instance_type = "db.t4g.medium"
  replica_count = 2

  storage_encrypted            = true
  apply_immediately            = true
  performance_insights_enabled = true
}

# RDS Aurora Serverless v2 (WIP)
module "aurora_db_serverless" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=2.1.0"

  vpc_name                     = var.vpc_name
  team_name                    = var.team_name
  business-unit                = var.business_unit
  application                  = var.application
  is-production                = var.is_production
  namespace                    = var.namespace
  environment-name             = var.environment-name
  infrastructure-support       = var.infrastructure_support

  engine         = "aurora-postgresql"
  engine_version = "14.6"
  engine_mode    = "provisioned"

  instance_type = "db.t4g.medium"
  replica_count = 2

  storage_encrypted            = true
  apply_immediately            = true
  performance_insights_enabled = true
}
