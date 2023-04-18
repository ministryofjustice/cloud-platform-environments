##
## PostgreSQL
##

module "ppud_replacement_bandiera_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"

  vpc_name               = var.vpc_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name          = "ppud-replacement-bandiera-dev"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13"
  db_instance_class = "db.t3.small"
  db_name           = "bandiera"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ppud_replacement_bandiera_rds" {
  metadata {
    name      = "bandiera-database"
    namespace = var.namespace
  }

  data = {
    host         = module.ppud_replacement_bandiera_rds.rds_instance_address
    port         = module.ppud_replacement_bandiera_rds.rds_instance_port
    endpoint     = module.ppud_replacement_bandiera_rds.rds_instance_endpoint
    dbname       = module.ppud_replacement_bandiera_rds.database_name
    username     = module.ppud_replacement_bandiera_rds.database_username
    password     = module.ppud_replacement_bandiera_rds.database_password
    DATABASE_URL = "postgres://${module.ppud_replacement_bandiera_rds.database_username}:${module.ppud_replacement_bandiera_rds.database_password}@${module.ppud_replacement_bandiera_rds.rds_instance_endpoint}/${module.ppud_replacement_bandiera_rds.database_name}"
  }
}

##
## Basic Auth
##

resource "random_string" "ppud_replacement_bandiera_basic_auth_username" {
  length  = 12
  special = false
  lower   = true
  upper   = true
}

resource "random_password" "ppud_replacement_bandiera_basic_auth_password" {
  length  = 24
  special = false
  lower   = true
  upper   = true
}

resource "kubernetes_secret" "ppud_replacement_bandiera_basic_auth" {
  metadata {
    name      = "bandiera-basic-auth"
    namespace = var.namespace
  }

  data = {
    username = random_string.ppud_replacement_bandiera_basic_auth_username.result
    password = random_password.ppud_replacement_bandiera_basic_auth_password.result
    auth     = "${random_string.ppud_replacement_bandiera_basic_auth_username.result}:${bcrypt(random_password.ppud_replacement_bandiera_basic_auth_password.result)}"
  }

  lifecycle {
    ignore_changes = [data]
  }
}
