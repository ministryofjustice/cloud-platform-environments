module "candidate_matching_rds" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=6.0.1"
  vpc_name                    = var.vpc_name
  team_name                   = var.team_name
  business_unit               = var.business_unit
  application                 = "candidate-matching-api"
  is_production               = var.is_production
  namespace                   = var.namespace
  environment_name            = var.environment
  infrastructure_support      = var.infrastructure_support
  rds_family                  = "postgres15"
  allow_major_version_upgrade = "false"
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "10000"
  db_engine_version           = "15"
  deletion_protection         = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "candidate_matching_rds" {
  metadata {
    name      = "rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.candidate_matching_rds.rds_instance_endpoint
    database_name         = module.candidate_matching_rds.database_name
    database_username     = module.candidate_matching_rds.database_username
    database_password     = module.candidate_matching_rds.database_password
    rds_instance_address  = module.candidate_matching_rds.rds_instance_address
    url                   = "postgres://${module.candidate_matching_rds.database_username}:${module.candidate_matching_rds.database_password}@${module.candidate_matching_rds.rds_instance_endpoint}/${module.candidate_matching_rds.database_name}"
  }
}