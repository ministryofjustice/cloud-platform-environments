/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "doc_gen_postgres" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  prepare_for_major_upgrade    = false
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = true
  performance_insights_enabled = false
  storage_type                 = "gp3"
  db_max_allocated_storage     = "50"
  db_allocated_storage         = "20"

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "18"
  rds_family        = "postgres18"
  db_instance_class = "db.t4g.micro"

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

resource "kubernetes_secret" "doc_gen_rds" {
  metadata {
    name      = "hmpps-document-generation-api-postgres"
    namespace = var.namespace
  }

  data = {
    database_name         = module.doc_gen_postgres.database_name
    database_username     = module.doc_gen_postgres.database_username
    database_password     = module.doc_gen_postgres.database_password
    database_server       = module.doc_gen_postgres.rds_instance_address
  }
}
