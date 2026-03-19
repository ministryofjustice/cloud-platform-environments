module "arns_assessment_view_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  prepare_for_major_upgrade    = false
  performance_insights_enabled = false
  deletion_protection          = true
  db_max_allocated_storage     = "500"

  # PostgreSQL specifics
  db_allocated_storage = 20
  storage_type         = "gp3"
  rds_family           = "postgres18"
  db_engine            = "postgres"
  db_engine_version    = "18"
  db_instance_class    = "db.t4g.micro"

  # Tags
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # Name
  rds_name = "hmpps-arns-assessment-view-db-${var.environment}"

  enable_irsa = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "arns_assessment_view_rds" {
  metadata {
    name      = "rds-arns-assessment-view-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.arns_assessment_view_rds.rds_instance_endpoint
    database_name         = module.arns_assessment_view_rds.database_name
    database_username     = module.arns_assessment_view_rds.database_username
    database_password     = module.arns_assessment_view_rds.database_password
    rds_instance_address  = module.arns_assessment_view_rds.rds_instance_address
    url                   = "postgres://${module.arns_assessment_view_rds.database_username}:${module.arns_assessment_view_rds.database_password}@${module.arns_assessment_view_rds.rds_instance_endpoint}/${module.arns_assessment_view_rds.database_name}"
  }
}
