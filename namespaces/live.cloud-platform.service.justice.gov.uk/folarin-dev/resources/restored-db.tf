module "restored_db" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=8.0.1"

  # Unique identifiers
  application            = "restored-db"  # different from the original
  db_instance_name       = "restored-v16-instance"
  
  # Snapshot config
  snapshot_identifier    = "manual-pre-v17-upgrade-20250221-161407"
  skip_final_snapshot    = true
  deletion_protection    = false

  # Reuse other config
  vpc_name               = var.vpc_name
  db_engine_version      = "16.3"
  rds_family             = "postgres16"
  db_instance_class      = "db.t4g.micro"
}

# Unique secret name
resource "kubernetes_secret" "restored_db" {
  metadata {
    name      = "restored-db-postgresql-output"  # unique name
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.restored_db.rds_instance_endpoint
    database_name         = module.restored_db.database_name
    database_username     = module.restored_db.database_username
    database_password     = module.restored_db.database_password
  }
}