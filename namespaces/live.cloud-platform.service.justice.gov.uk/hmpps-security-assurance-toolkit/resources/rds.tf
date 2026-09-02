module "hmpps_security_assurance_toolkit_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage        = 20
  storage_type                = "gp2"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = "hmpps-security-assurance-toolkit"
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500" # maximum storage for autoscaling
  db_engine_version           = "17"
  rds_family                  = "postgres17"

  providers = {
    aws = aws.london
  }

}


resource "kubernetes_secret" "hmpps_security_assurance_toolkit_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = "hmpps-security-assurance-toolkit"
  }

  data = {
    DATABASE_URL = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

########################################################################################################
#if there are multiple databases provisioned, then those names should be added in local variable as well. Like
#rds_databases = {
# "rdsAlertsDatabases.${module.hmpps_service_catalogue1.db_identifier1}" = "hmpps-service-catalogue-db1"
# "rdsAlertsDatabases.${module.hmpps_service_catalogue2.db_identifier2}" = "hmpps-service-catalogue-db2"
#}
########################################################################################################## 

locals {

  rds_databases = {
    "rdsAlertsDatabases.${module.hmpps_security_assurance_toolkit_rds.db_identifier}" = "hmpps-security-assurance-toolkit-db"

  }

  database_list = flatten([
    for identifier, desc in local.rds_databases : {
      identifier = identifier
      desc       = desc
    }
  ])

  database_details = {
    for m in local.database_list : (m.identifier) => m
  }
}
resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}