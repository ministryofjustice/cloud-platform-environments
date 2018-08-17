terraform {
#  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=master"

  team_name                   = "formbuilder-dev"
  db_backup_retention_period  = "2"
  application                 = "formbuilderpublisher"
  environment-name            = "dev"
  is-production               = "false"
  infrastructure-support      = "Form Builder form-builder-team@digital.justice.gov.uk"
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-publisher-dev"
    namespace = "formbuilder-platform-dev"
  }

  data {
    instance_id         = "${module.rds-instance.rds_instance_id}"
    arn                 = "${module.rds-instance.rds_instance_arn}"
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url                 = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
    kms_key_id          = "${module.rds-instance.kms_key_id}"
    access_key_id       = "${module.rds-instance.access_key_id}"
    secret_access_key   = "${module.rds-instance.secret_access_key}"
  }
}
