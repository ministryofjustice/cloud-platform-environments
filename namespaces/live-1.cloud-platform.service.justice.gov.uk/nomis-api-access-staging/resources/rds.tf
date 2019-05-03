variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "nomis-api-access_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.2"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "Digital Prison Services/New Nomis"
  business-unit          = "HMPPS"
  application            = "nomis-api-access"
  is-production          = "false"
  environment-name       = "staging"
  infrastructure-support = "matt.whittaker@digtal.justice.gov.uk"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "nomis-api-access_rds" {
  metadata {
    name      = "nomis-api-access-rds-instance-output"
    namespace = "nomis-api-access-staging"
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
