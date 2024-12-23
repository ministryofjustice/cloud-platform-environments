module "prisons_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.prison-application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  db_instance_class         = "db.t4g.small"
  db_engine                 = "postgres"
  db_engine_version         = "16.3"
  rds_family                = "postgres16"
  db_max_allocated_storage  = "10000"
    # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade = false
  deletion_protection       = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisons_rds" {
  metadata {
    name      = "prisons-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prisons_rds.rds_instance_endpoint
    database_name         = module.prisons_rds.database_name
    database_username     = module.prisons_rds.database_username
    database_password     = module.prisons_rds.database_password
    rds_instance_address  = module.prisons_rds.rds_instance_address
  }
}
