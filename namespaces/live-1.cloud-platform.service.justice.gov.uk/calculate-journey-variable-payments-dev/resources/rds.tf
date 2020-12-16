module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name         = var.cluster_name
  cluster_state_bucket = var.cluster_state_bucket

  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  namespace              = var.namespace
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name

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
