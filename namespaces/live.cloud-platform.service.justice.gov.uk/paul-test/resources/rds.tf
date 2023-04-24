module "wp_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  # using mysql
  db_engine         = "mysql"
  db_engine_version = "8.0.28"
  rds_family        = "mysql8.0"
  db_instance_class = "db.t4g.small"

  # overwrite db_parameters.
  db_parameter = [
    {
      name         = "character_set_client"
      value        = "utf8"
      apply_method = "immediate"
    },
    {
      name         = "character_set_server"
      value        = "utf8"
      apply_method = "immediate"
    }
  ]


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "wp_rds" {
  metadata {
    name      = "wp-rds-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.wp_rds.rds_instance_endpoint
    database_name         = module.wp_rds.database_name
    database_username     = module.wp_rds.database_username
    database_password     = module.wp_rds.database_password
    rds_instance_address  = module.wp_rds.rds_instance_address
    access_key_id         = module.wp_rds.access_key_id
    secret_access_key     = module.wp_rds.secret_access_key
  }
}

