module "rds-instance" {
  source = "https://github.com/ministryofjustice/cloud-platform-terraform-rds-instance/tree/add-oracle"
  vpc_name = var.vpc_name

  application            = var.application
  environment_name       = var.environment-name
  is_production          = var.is_production
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit

  enable_rds_auto_start_stop = true


 # Database configuration
  db_engine                = "oracle-se2" # or oracle-ee
  db_engine_version        = "19.0.0.0.ru-2019-07.rur-2019-07.r1"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.small"
  db_max_allocated_storage = "500"
  license_model = "license-included"
  db_iops = 0
  character_set_name = "WE8MSWIN1252"   # problem  
 
  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

  db_parameter = [
    {
      name         = "rds.force_ssl"
      value        = "0"
      apply_method = "immediate"
    }
  ]
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-calculate-journey-variable-payments-${var.environment-name}"
    namespace = var.namespace
  }

  data = {
    database_name     = module.rds-instance.database_name
    database_host     = module.rds-instance.rds_instance_address
    database_port     = module.rds-instance.rds_instance_port
    database_username = module.rds-instance.database_username
    database_password = module.rds-instance.database_password
  }
}
