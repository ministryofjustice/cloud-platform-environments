module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name             = var.vpc_name
  db_engine_version    = "16"
  rds_family           = "postgres16"
  db_instance_class        = "db.t3.micro"
  db_allocated_storage     = 10
  db_max_allocated_storage = 100
  storage_type             = "gp3"

  prepare_for_major_upgrade = "false"
  enable_irsa               = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "github_actions_environment_secret" "database_connection_string" {
  repository      = "onboarding-optimisation"
  environment     = "dev"
  secret_name     = "DATABASE_CONNECTION_STRING"
  plaintext_value = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
}
