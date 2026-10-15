module "court_data_adaptor_rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 10
  storage_type         = "gp2"
  vpc_name             = var.vpc_name
  namespace            = var.namespace
  team_name            = "laa-crime-apps-team"
  business_unit        = "Crime Apps"
  application          = "laa-court-data-adaptor"
  is_production        = "true"

  environment_name       = "prod"
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres17"
  db_engine_version      = "17.11"

  allow_major_version_upgrade = "true"
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "11000"
  deletion_protection         = true
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }


  enable_irsa = true
}

module "court_data_adaptor_rds_read_replica" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  db_allocated_storage = 10
  storage_type         = "gp2"
  vpc_name             = var.vpc_name
  namespace            = var.namespace
  team_name            = "laa-crime-apps-team"
  business_unit        = "Crime Apps"
  application          = "laa-court-data-adaptor"
  is_production        = "false"

  db_engine_version        = "17.11"
  environment_name         = "test"
  infrastructure_support   = var.infrastructure_support
  rds_family               = "postgres17"
  db_max_allocated_storage = "11000"

  db_instance_class = "db.t4g.small"

  replicate_source_db        = module.court_data_adaptor_rds.db_identifier
  skip_final_snapshot        = "true"
  db_backup_retention_period = 0

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "court_data_adaptor_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = "laa-court-data-adaptor-prod"
  }

  data = {
    database_name         = module.court_data_adaptor_rds.database_name
    database_username     = module.court_data_adaptor_rds.database_username
    rds_instance_address  = module.court_data_adaptor_rds.rds_instance_address
    rds_instance_endpoint = module.court_data_adaptor_rds.rds_instance_endpoint
    url                   = "postgres://${module.court_data_adaptor_rds.database_username}:${module.court_data_adaptor_rds.database_password}@${module.court_data_adaptor_rds.rds_instance_endpoint}/${module.court_data_adaptor_rds.database_name}"
  }
}

resource "kubernetes_secret" "court_data_adaptor_rds_read_replica" {
  metadata {
    name      = "rds-instance-read-replica-output"
    namespace = "laa-court-data-adaptor-prod"
  }

  data = {
    rds_instance_address  = module.court_data_adaptor_rds_read_replica.rds_instance_address
    rds_instance_endpoint = module.court_data_adaptor_rds_read_replica.rds_instance_endpoint
    url                   = "postgres://${module.court_data_adaptor_rds.database_username}:${module.court_data_adaptor_rds.database_password}@${module.court_data_adaptor_rds_read_replica.rds_instance_endpoint}/${module.court_data_adaptor_rds_read_replica.database_name}"
  }
}

