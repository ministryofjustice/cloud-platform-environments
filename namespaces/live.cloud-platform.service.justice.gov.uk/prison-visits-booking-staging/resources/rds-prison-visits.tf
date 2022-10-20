/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

variable "cluster_name" {
}

variable "vpc_name" {
}


/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 * 
 */

module "prison-visits-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.13"

  vpc_name               = var.vpc_name
  team_name              = "prison-visits-booking"
  db_instance_class      = "db.m5.large"
  db_allocated_storage   = "50"
  business-unit          = "HMPPS"
  application            = "prison-visits-booking-staging"
  is-production          = "false"
  namespace              = var.namespace
  environment-name       = "staging"
  infrastructure-support = "pvb-technical-support@digital.justice.gov.uk"
  db_engine              = "postgres"
  db_engine_version      = "12"
  db_name                = "visits"
  db_parameter           = [{ name = "rds.force_ssl", value = "0", apply_method = "immediate" }]
  rds_family             = "postgres12"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prison-visits-rds" {
  metadata {
    name      = "prison-visits-rds-instance-output"
    namespace = "prison-visits-booking-staging"
  }

  data = {
    access_key_id     = module.prison-visits-rds.access_key_id
    secret_access_key = module.prison-visits-rds.secret_access_key
    url               = "postgres://${module.prison-visits-rds.database_username}:${module.prison-visits-rds.database_password}@${module.prison-visits-rds.rds_instance_endpoint}/${module.prison-visits-rds.database_name}"
  }
}

