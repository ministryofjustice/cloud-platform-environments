module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name                 = var.vpc_name
  db_engine               = "postgres"
  db_engine_version       = "17"
  rds_family              = "postgres17"
  db_instance_class       = "db.t4g.micro"
  db_max_allocated_storage = "500"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace

  enable_irsa = true
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    rds_instance_address  = module.rds.rds_instance_address
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    database_url          = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}

resource "kubernetes_secret" "rds-spring" {
  metadata {
    name      = "rds-spring"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_USERNAME = module.rds.database_username
    SPRING_DATASOURCE_PASSWORD = module.rds.database_password
    SPRING_DATASOURCE_URL = "jdbc:postgresql://${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
  }
}
