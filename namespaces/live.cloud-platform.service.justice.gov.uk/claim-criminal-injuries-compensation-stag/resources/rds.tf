module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"

  storage_type = "gp2"

  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.email

  db_engine                    = "postgres"
  db_engine_version            = "14.12"
  db_instance_class            = "db.t4g.micro"
  db_allocated_storage         = "50"
  db_max_allocated_storage     = "500"
  db_name                      = "datacaptureservice"
  db_backup_retention_period   = var.db_backup_retention_period
  deletion_protection          = true
  performance_insights_enabled = true

  enable_rds_auto_start_stop = true

  # rds_family should be: postgres14
  # Pick the one that defines the postgres version the best
  rds_family = "postgres14"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-stag"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    rds_instance_port     = module.rds.rds_instance_port
  }
}
