module "ciag_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business-unit               = var.business_unit
  application                 = "ciag-careers-induction-api"
  is-production               = var.is_production
  namespace                   = var.namespace
  environment-name            = var.environment
  infrastructure-support      = var.infrastructure_support
  rds_family                  = "postgres15"
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "10000"
  db_engine_version           = "15"
  deletion_protection         = true

  providers = {
	aws = aws.london
  }
}

resource "kubernetes_secret" "ciag_rds" {
  metadata {
	name      = "ciag-rds-instance-output"
	namespace = var.namespace
  }

  data = {
	rds_instance_endpoint = module.ciag_rds.rds_instance_endpoint
	database_name         = module.ciag_rds.database_name
	database_username     = module.ciag_rds.database_username
	database_password     = module.ciag_rds.database_password
	rds_instance_address  = module.ciag_rds.rds_instance_address
	access_key_id         = module.ciag_rds.access_key_id
	secret_access_key     = module.ciag_rds.secret_access_key
	url                   = "postgres://${module.ciag_rds.database_username}:${module.ciag_rds.database_password}@${module.ciag_rds.rds_instance_endpoint}/${module.ciag_rds.database_name}"
  }
}

