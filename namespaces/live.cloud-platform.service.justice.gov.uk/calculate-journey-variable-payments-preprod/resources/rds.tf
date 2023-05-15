module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name = var.vpc_name

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is_production
  namespace              = var.namespace
  infrastructure-support = var.infrastructure_support
  team_name              = var.team_name

  enable_rds_auto_start_stop  = true

  db_engine         = "postgres"
  db_engine_version = "12.11"
  db_instance_class = "db.t4g.small"

  rds_family = "postgres12"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "0"
      apply_method = "immediate"
    }
  ]
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-calculate-journey-variable-payments-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.rds-instance.access_key_id
    secret_access_key = module.rds-instance.secret_access_key
    database_name     = module.rds-instance.database_name
    database_host     = module.rds-instance.rds_instance_address
    database_port     = module.rds-instance.rds_instance_port
    database_username = module.rds-instance.database_username
    database_password = module.rds-instance.database_password
  }
}
