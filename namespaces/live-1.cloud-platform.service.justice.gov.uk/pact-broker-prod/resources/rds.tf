module "pact_broker_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pact_broker_rds_secrets" {
  metadata {
    name      = "database"
    namespace = var.namespace
  }

  data = {
    host     = module.pact_broker_rds.rds_instance_address
    name     = module.pact_broker_rds.database_name
    username = module.pact_broker_rds.database_username
    password = module.pact_broker_rds.database_password
  }
}
