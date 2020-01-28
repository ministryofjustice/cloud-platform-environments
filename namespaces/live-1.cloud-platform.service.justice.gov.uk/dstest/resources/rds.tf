variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "dstest_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=prevent_destroy"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support
  force_ssl              = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dstest_rds_secret" {
  metadata {
    name      = "dstest_rds_secret"
    namespace = "dstest"
  }

  data = {
    url = "postgres://${module.dstest_rds.database_username}:${module.dstest_rds.database_password}@${module.dstest_rds.rds_instance_endpoint}/${module.dstest_rds.database_name}"
  }
}
