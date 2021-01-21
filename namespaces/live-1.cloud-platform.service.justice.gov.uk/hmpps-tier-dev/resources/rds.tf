/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

module "hmpps_tier_dev_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.12"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "manage-a-sentence"
  business-unit          = "HMPPS"
  application            = "manage-a-sentence"
  is-production          = "false"
  namespace              = var.namespace
  environment-name       = "development"
  infrastructure-support = "hmpps@digital.justice.gov.uk"
  rds_family             = "postgres10"
  db_parameter           = [{ name = "rds.force_ssl", value = "1", apply_method = "immediate" }]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_tier_rds_secrets" {
  metadata {
    name      = "hmpps-tier-rds"
    namespace = "hmpps-tier-dev"
  }

  data = {
    rds_instance_endpoint = module.hmpps_tier_dev_rds.rds_instance_endpoint
    database_name         = module.hmpps_tier_dev_rds.database_name
    rds_instance_port     = module.hmpps_tier_dev_rds.rds_instance_port
    database_username     = module.hmpps_tier_dev_rds.database_username
    database_password     = module.hmpps_tier_dev_rds.database_password
    rds_instance_address  = module.hmpps_tier_dev_rds.rds_instance_address
  }
}

# For deletion...
resource "kubernetes_secret" "hmpps_tier_dev_rds" {
  metadata {
    name      = "hmpps-tier-dev-env"
    namespace = "hmpps-tier-dev"
  }

  data = {
    rds_instance_endpoint = module.hmpps_tier_dev_rds.rds_instance_endpoint
    database_name         = module.hmpps_tier_dev_rds.database_name
    rds_instance_port     = module.hmpps_tier_dev_rds.rds_instance_port
    database_username     = module.hmpps_tier_dev_rds.database_username
    database_password     = module.hmpps_tier_dev_rds.database_password
    rds_instance_address  = module.hmpps_tier_dev_rds.rds_instance_address
  }
}

