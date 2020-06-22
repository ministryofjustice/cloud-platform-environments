/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "pcs_sonarqube_rds_2" {
  source                      = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.6"
  cluster_name                = var.cluster_name
  cluster_state_bucket        = var.cluster_state_bucket
  team_name                   = var.team_name
  business-unit               = var.business-unit
  application                 = var.application
  is-production               = var.is-production
  environment-name            = var.environment-name
  infrastructure-support      = var.infrastructure-support
  db_allocated_storage        = "25"
  db_instance_class           = "db.t3.medium"
  db_engine_version           = "9.6"
  rds_family                  = "postgres9.6"
  allow_major_version_upgrade = "true"


  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "pcs_sonarqube_rds_2" {
  metadata {
    name      = "pcs-sonarqube-rds-2"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.pcs_sonarqube_rds_2.rds_instance_endpoint
    database_name         = module.pcs_sonarqube_rds_2.database_name
    database_username     = module.pcs_sonarqube_rds_2.database_username
    database_password     = module.pcs_sonarqube_rds_2.database_password
    rds_instance_address  = module.pcs_sonarqube_rds_2.rds_instance_address
    url                   = "postgres://${module.pcs_sonarqube_rds_2.database_username}:${module.pcs_sonarqube_rds_2.database_password}@${module.pcs_sonarqube_rds_2.rds_instance_endpoint}/${module.pcs_sonarqube_rds_2.database_name}"
  }
}

