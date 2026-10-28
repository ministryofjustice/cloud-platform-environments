# TEMPORARY: restore rehearsal. Creates a separate instance from a manual
# snapshot so the live UAT database is untouched. Remove this file once the
# restore has been verified (see docs/runbooks/rds-snapshots.md in
# laa-info-and-advice-datastore).
module "rds_restore_test" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  vpc_name = var.vpc_name
  rds_name = "laa-info-and-advice-datastore-uat-restore-test"

  snapshot_identifier = "laa-info-and-advice-datastore-uat-restore-test-20261028"
  is_migration        = true

  # Must match the snapshot
  db_engine            = "postgres"
  db_engine_version    = "18.6"
  rds_family           = "postgres18"
  db_allocated_storage = "20"

  db_instance_class        = "db.t4g.micro"
  db_max_allocated_storage = "100"

  allow_minor_version_upgrade = true
  allow_major_version_upgrade = false

  # Test instance only: no final snapshot, no auto-start/stop
  skip_final_snapshot          = "true"
  performance_insights_enabled = false

  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "rds_restore_test" {
  metadata {
    name      = "rds-restore-test-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_restore_test.rds_instance_endpoint
    database_name         = module.rds_restore_test.database_name
    database_username     = module.rds_restore_test.database_username
    database_password     = module.rds_restore_test.database_password
    rds_instance_address  = module.rds_restore_test.rds_instance_address
  }
}
