module "prison-visits-rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.19.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  allow_major_version_upgrade = "true"
  enable_rds_auto_start_stop  = true
  db_instance_class           = "db.t4g.small"
  rds_family                  = "postgres12"
  db_engine_version           = "12.13"
  db_allocated_storage        = "50"
  db_engine                   = "postgres"
  db_name                     = "visits"
  db_parameter                = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  db_password_rotated_date    = "2023-03-22"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prison-visits-rds" {
  metadata {
    name      = "prison-visits-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prison-visits-rds.access_key_id
    secret_access_key = module.prison-visits-rds.secret_access_key
    url               = "postgres://${module.prison-visits-rds.database_username}:${module.prison-visits-rds.database_password}@${module.prison-visits-rds.rds_instance_endpoint}/${module.prison-visits-rds.database_name}"
  }
}
