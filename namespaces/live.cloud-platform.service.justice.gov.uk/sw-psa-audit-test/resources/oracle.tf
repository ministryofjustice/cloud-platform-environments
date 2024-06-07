module "rds-instance" {
  source   = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.2"
  vpc_name = var.vpc_name

  application            = var.application
  environment_name       = var.environment
  is_production          = var.is_production
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name
  business_unit          = var.business_unit

  enable_rds_auto_start_stop = true


  # Database configuration
  db_engine                = "oracle-se2" # or oracle-ee
  db_engine_version        = "19.0.0.0.ru-2024-01.rur-2024-01.r1"
  rds_family               = "oracle-se2-19"
  db_instance_class        = "db.t3.medium"
  db_allocated_storage     = "300"
  db_max_allocated_storage = "500"
  db_name                  = "TEST"
  license_model            = "license-included"
  db_iops                  = 0
  character_set_name       = "WE8MSWIN1252" # problem  

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "false"

  # enable performance insights
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

  # passing emplty list as oracle repo has parameter defined 
  db_parameter = []

  snapshot_identifier = "arn:aws:rds:eu-west-2:754256621582:snapshot:steve-test-oracle-db-snapshot"
}





resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-oracle-${var.environment}"
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
