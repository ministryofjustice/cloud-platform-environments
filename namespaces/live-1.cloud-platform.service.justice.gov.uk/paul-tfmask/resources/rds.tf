/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "paul-tfmask-rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.6"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "WebOps"
  business-unit          = "MOJ DIGITAL"
  application            = "paul-tfmask"
  is-production          = "false"
  environment-name       = "dev"
  infrastructure-support = ""
  db_engine              = "postgres"
  db_engine_version      = "11.4"
  db_name                = "paultfmask"
  rds_family             = "postgres11"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "paul-tfmask" {
  metadata {
    name      = "paul-tfmask"
    namespace = "paul-tfmask"
  }

  data = {
    rds_instance_endpoint = module.paul-tfmask-rds.rds_instance_endpoint
    database_name         = module.paul-tfmask-rds.database_name
    database_username     = module.paul-tfmask-rds.database_username
    database_password     = module.paul-tfmask-rds.database_password
    rds_instance_address  = module.paul-tfmask-rds.rds_instance_address
    access_key_id         = module.paul-tfmask-rds.access_key_id
    secret_access_key     = module.paul-tfmask-rds.secret_access_key
    url                   = "postgres://${module.paul-tfmask-rds.database_username}:${module.paul-tfmask-rds.database_password}@${module.paul-tfmask-rds.rds_instance_endpoint}/${module.paul-tfmask-rds.database_name}"
  }
}

