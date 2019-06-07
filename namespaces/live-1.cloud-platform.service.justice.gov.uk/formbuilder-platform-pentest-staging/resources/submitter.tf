# auto-generated from fb-cloud-platforms-environments
##################################################
# Submitter RDS

module "submitter-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.1"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  db_backup_retention_period = "${var.db_backup_retention_period_submitter}"
  application                = "formbuildersubmitter"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
}

resource "kubernetes_secret" "submitter-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-submitter-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.submitter-rds-instance.database_username}:${module.submitter-rds-instance.database_password}@${module.submitter-rds-instance.rds_instance_endpoint}/${module.submitter-rds-instance.database_name}"
  }
}

##################################################

########################################################
# Submitter Elasticache Redis (for resque + job logging)
module "submitter-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=3.0"

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  application            = "formbuildersubmitter"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "submitter-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-submitter-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data {
    primary_endpoint_address = "${module.submitter-elasticache.primary_endpoint_address}"
    auth_token               = "${module.submitter-elasticache.auth_token}"
  }
}
