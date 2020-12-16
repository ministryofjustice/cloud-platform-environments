/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "checkmydiary_dev_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "check-my-diary"
  business-unit          = "HMPPS"
  application            = "check-my-diary"
  is-production          = "false"
  namespace              = var.namespace
  environment-name       = "development"
  infrastructure-support = "checkmydiary@digital.justice.gov.uk"
  rds_family             = "postgres10"
  db_parameter           = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "checkmydiary_rds_secrets" {
  metadata {
    name      = "check-my-diary-rds"
    namespace = "check-my-diary-dev"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_dev_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_dev_rds.database_name
    rds_instance_port     = module.checkmydiary_dev_rds.rds_instance_port
    database_username     = module.checkmydiary_dev_rds.database_username
    database_password     = module.checkmydiary_dev_rds.database_password
    rds_instance_address  = module.checkmydiary_dev_rds.rds_instance_address
  }
}

# For deletion...
resource "kubernetes_secret" "checkmydiary_dev_rds" {
  metadata {
    name      = "check-my-diary-rds-dev-env"
    namespace = "check-my-diary-dev"
  }

  data = {
    rds_instance_endpoint = module.checkmydiary_dev_rds.rds_instance_endpoint
    database_name         = module.checkmydiary_dev_rds.database_name
    rds_instance_port     = module.checkmydiary_dev_rds.rds_instance_port
    database_username     = module.checkmydiary_dev_rds.database_username
    database_password     = module.checkmydiary_dev_rds.database_password
    rds_instance_address  = module.checkmydiary_dev_rds.rds_instance_address
  }
}

