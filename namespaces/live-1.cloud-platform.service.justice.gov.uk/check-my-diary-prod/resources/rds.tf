/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "checkmydiary_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.0"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "check-my-diary"
  application            = "check-my-diary"
  is-production          = "true"
  environment-name       = "prod"
  infrastructure-support = "checkmydiary@digital.justice.gov.uk"
  force_ssl              = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "checkmydiary_rds" {
  metadata {
    name      = "check-my-diary-rds-prod"
    namespace = "check-my-diary-prod"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_rds.database_name
    database_username     = module.checkmydiary_rds.database_username
    database_password     = module.checkmydiary_rds.database_password
    rds_instance_address  = module.checkmydiary_rds.rds_instance_address
  }
}

