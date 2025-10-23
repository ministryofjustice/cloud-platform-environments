/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "complexity-of-need-rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 10
  storage_type         = "gp2"

  vpc_name                   = var.vpc_name
  db_instance_class          = "db.t4g.micro"
  db_max_allocated_storage   = "500"
  team_name                  = var.team_name
  business_unit              = "HMPPS"
  application                = "hmpps-complexity-of-need"
  is_production              = "false"
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = "manage-pom-cases@digital.justice.gov.uk"
  db_engine                  = "postgres"
  db_name                    = "hmpps_complexity_of_need"
  enable_rds_auto_start_stop = true # 22:00–06:00 UTC
  maintenance_window         = "sun:19:00-sun:21:00"

  db_engine_version           = "15.12"
  rds_family                  = "postgres15"
  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.complexity-of-need-rds.rds_instance_endpoint
    database_name         = module.complexity-of-need-rds.database_name
    database_username     = module.complexity-of-need-rds.database_username
    database_password     = module.complexity-of-need-rds.database_password
    rds_instance_address  = module.complexity-of-need-rds.rds_instance_address
  }
}

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.complexity-of-need-rds.database_name
    db_identifier = module.complexity-of-need-rds.db_identifier
  }
}
