variable "cluster_name" {}

variable "cluster_state_bucket" {}

module "mattwhittaker_team_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.1"
  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "mattwhittaker-repo"
  business-unit          = "mattwhittaker-bu"
  application            = "mattwhittakerapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "matt.whittaker@digtal.justice.gov.uk"
  aws_region             = "eu-west-2"
}

resource "kubernetes_secret" "mattwhittaker_team_rds" {
  metadata {
    name      = "mattwhittaker-team-rds-instance-output"
    namespace = "mattwhittaker-dev"
  }

  data {
    rds_instance_endpoint = "${module.mattwhittaker_team_rds.rds_instance_endpoint}"
    database_name         = "${module.mattwhittaker_team_rds.database_name}"
    database_username     = "${module.mattwhittaker_team_rds.database_username}"
    database_password     = "${module.mattwhittaker_team_rds.database_password}"
    rds_instance_address  = "${module.mattwhittaker_team_rds.rds_instance_address}"
    url = "postgres://${module.mattwhittaker_team_rds.database_username}:${module.mattwhittaker_team_rds.database_password}@${module.mattwhittaker_team_rds.rds_instance_endpoint}/${module.mattwhittaker_team_rds.database_name}"
  }
}
