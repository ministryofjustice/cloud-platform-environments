
module "hmpps-court-data-ingestion-api-rds" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  # VPC configuration
  vpc_name = var.vpc_name

  # PostgreSQL specifics
  db_instance_class            = "db.t4g.micro"
  db_max_allocated_storage     = "500"
  db_engine                    = "postgres"
  rds_family                   = "postgres18"
  db_engine_version            = "18"
  prepare_for_major_upgrade    = false
  enable_rds_auto_start_stop   = false
  storage_type                 = "gp3"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  enable_irsa = true
}


resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps-court-data-ingestion-api-rds.rds_instance_endpoint
    database_name         = module.hmpps-court-data-ingestion-api-rds.database_name
    db_identifier         = module.hmpps-court-data-ingestion-api-rds.db_identifier
    database_username     = module.hmpps-court-data-ingestion-api-rds.database_username
    database_password     = module.hmpps-court-data-ingestion-api-rds.database_password
    rds_instance_address  = module.hmpps-court-data-ingestion-api-rds.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}
