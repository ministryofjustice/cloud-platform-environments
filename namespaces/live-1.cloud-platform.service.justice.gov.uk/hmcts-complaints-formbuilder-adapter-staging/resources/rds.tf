module "hmcts-complaints-adapter-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=4.6"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  db_backup_retention_period = "${var.db_backup_retention_period_hmcts_complaints_adapter}"
  application                = "hmcts-complaints-formbuilder-adapter"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
  force_ssl                  = true
  db_engine_version          = "11.4"
  rds_family                 = "postgres11"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "hmcts-complaints-adapter-rds-instance" {
  metadata {
    name      = "rds-instance-hmcts-complaints-adapter-${var.environment-name}"
    namespace = "hmcts-complaints-formbuilder-adapter-${var.environment-name}"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.hmcts-complaints-adapter-rds-instance.database_username}:${module.hmcts-complaints-adapter-rds-instance.database_password}@${module.hmcts-complaints-adapter-rds-instance.rds_instance_endpoint}/${module.hmcts-complaints-adapter-rds-instance.database_name}"
  }
}
