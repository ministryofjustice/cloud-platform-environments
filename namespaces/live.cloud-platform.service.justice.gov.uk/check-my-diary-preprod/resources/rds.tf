module "checkmydiary_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.13"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = "HMPPS"
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  rds_family             = "postgres10"
  db_parameter           = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "checkmydiary_rds_secrets" {
  metadata {
    name      = "check-my-diary-rds"
    namespace = "check-my-diary-preprod"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_rds.database_name
    database_username     = module.checkmydiary_rds.database_username
    database_password     = module.checkmydiary_rds.database_password
    rds_instance_address  = module.checkmydiary_rds.rds_instance_address
  }
}

# For deletion...
resource "kubernetes_secret" "checkmydiary_rds" {
  metadata {
    name      = "check-my-diary-rds-preprod"
    namespace = "check-my-diary-preprod"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_rds.database_name
    database_username     = module.checkmydiary_rds.database_username
    database_password     = module.checkmydiary_rds.database_password
    rds_instance_address  = module.checkmydiary_rds.rds_instance_address
  }
}

