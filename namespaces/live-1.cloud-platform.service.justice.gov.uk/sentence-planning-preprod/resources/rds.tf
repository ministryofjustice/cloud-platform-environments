variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "sentence-planning_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.2"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "Sentence Planning"
  business-unit          = "HMPPS"
  application            = "sentence-planning"
  is-production          = "false"
  environment-name       = "preprod"
  infrastructure-support = "michael.willis@digtal.justice.gov.uk"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "sentence-planning_rds" {
  metadata {
    name      = "sentence-planning-rds-instance-output"
    namespace = "sentence-planning-preprod"
  }

  data {
    rds_instance_endpoint = "${module.sentence-planning_rds.rds_instance_endpoint}"
    database_name         = "${module.sentence-planning_rds.database_name}"
    database_username     = "${module.sentence-planning_rds.database_username}"
    database_password     = "${module.sentence-planning_rds.database_password}"
    rds_instance_address  = "${module.sentence-planning_rds.rds_instance_address}"
    url                   = "postgres://${module.sentence-planning_rds.database_username}:${module.sentence-planning_rds.database_password}@${module.sentence-planning_rds.rds_instance_endpoint}/${module.sentence-planning_rds.database_name}"
  }
}
