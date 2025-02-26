module "restored_db" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"
  
  # Snapshot config
  snapshot_identifier    = "manual-pre-v17-upgrade-20250221-161407"
  skip_final_snapshot    = true
  deletion_protection    = false

  # Reuse other config
  vpc_name               = var.vpc_name
  db_engine_version      = "16.3"
  rds_family             = "postgres16"
  db_instance_class      = "db.t4g.micro"

  # Tags
  application            = "restored-db"  # different from the original
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = true
  db_max_allocated_storage     = "500"
  prepare_for_major_upgrade   = false
}

# Unique secret name
resource "kubernetes_secret" "restored_db_secret" {
  metadata {
    name      = "restored-db-postgresql-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.restored_db.rds_instance_endpoint
    database_name         = module.restored_db.database_name
    database_username     = module.restored_db.database_username
    database_password     = module.restored_db.database_password
  }
}