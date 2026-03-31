module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name

  # Engine
  db_engine         = "postgres"
  db_engine_version = "18.1"
  rds_family        = "postgres18"

  # Instance sizing
  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "500"

  # Upgrades
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false

  # Cost optimisation (not for prod)
  enable_rds_auto_start_stop = var.is_production ? false : true

  # Observability
  performance_insights_enabled = false

  # Tags (required by platform)
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}