module "court_data_adaptor_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
  db_allocated_storage = 10
  storage_type         = "gp2"
  vpc_name             = var.vpc_name
  namespace            = var.namespace
  team_name            = "laa-crime-apps-team"
  business_unit        = "Crime Apps"
  application          = "laa-court-data-adaptor"
  is_production        = "false"

  db_engine_version      = "17.4"
  environment_name       = "test"
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres17"

  allow_major_version_upgrade = "true"
  enable_rds_auto_start_stop  = true
  maintenance_window          = "Mon:21:00-Mon:22:00"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }


  enable_irsa = true
}

resource "kubernetes_secret" "court_data_adaptor_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = "laa-court-data-adaptor-test"
  }

  data = {
    database_name         = module.court_data_adaptor_rds.database_name
    database_username     = module.court_data_adaptor_rds.database_username
    rds_instance_address  = module.court_data_adaptor_rds.rds_instance_address
    rds_instance_endpoint = module.court_data_adaptor_rds.rds_instance_endpoint
    url                   = "postgres://${module.court_data_adaptor_rds.database_username}:${module.court_data_adaptor_rds.database_password}@${module.court_data_adaptor_rds.rds_instance_endpoint}/${module.court_data_adaptor_rds.database_name}"
  }
}
