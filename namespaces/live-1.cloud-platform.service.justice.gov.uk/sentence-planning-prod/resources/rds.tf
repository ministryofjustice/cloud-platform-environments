variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "sentence-planning_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "sentence-planning_rds" {
  metadata {
    name      = "sentence-planning-rds-instance-output"
    namespace = "sentence-planning-prod"
  }

  data = {
    rds_instance_endpoint = module.sentence-planning_rds.rds_instance_endpoint
    database_name         = module.sentence-planning_rds.database_name
    database_username     = module.sentence-planning_rds.database_username
    database_password     = module.sentence-planning_rds.database_password
    rds_instance_address  = module.sentence-planning_rds.rds_instance_address
    url                   = "postgres://${module.sentence-planning_rds.database_username}:${module.sentence-planning_rds.database_password}@${module.sentence-planning_rds.rds_instance_endpoint}/${module.sentence-planning_rds.database_name}"
  }
}

