variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "nomis-api-access_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.2"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "nomis-api-access_rds" {
  metadata {
    name      = "nomis-api-access-rds-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    rds_instance_endpoint = "${module.nomis-api-access_rds.rds_instance_endpoint}"
    database_name         = "${module.nomis-api-access_rds.database_name}"
    database_username     = "${module.nomis-api-access_rds.database_username}"
    database_password     = "${module.nomis-api-access_rds.database_password}"
    rds_instance_address  = "${module.nomis-api-access_rds.rds_instance_address}"
    url                   = "postgres://${module.nomis-api-access_rds.database_username}:${module.nomis-api-access_rds.database_password}@${module.nomis-api-access_rds.rds_instance_endpoint}/${module.nomis-api-access_rds.database_name}"
  }
}
