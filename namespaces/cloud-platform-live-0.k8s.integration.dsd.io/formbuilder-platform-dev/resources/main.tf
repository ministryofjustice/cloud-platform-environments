terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

##################################################
# Publisher RDS
module "rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=1.0"

  db_backup_retention_period = "2"

  application            = "formbuilderpublisher"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-publisher-dev"
    namespace = "formbuilder-platform-dev"
  }

  data {
    instance_id = "${module.rds-instance.rds_instance_id}"
    arn         = "${module.rds-instance.rds_instance_arn}"

    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url               = "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
    kms_key_id        = "${module.rds-instance.kms_key_id}"
    access_key_id     = "${module.rds-instance.access_key_id}"
    secret_access_key = "${module.rds-instance.secret_access_key}"
  }
}

##################################################

########################################################
# Publisher Elasticache Redis (for resque + job logging)
module "publisher-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=1.0"

  ec_engine       = "redis"
  number_of_nodes = 1

  cluster_name         = "${var.cluster_name}"
  cluster_state_bucket = "${var.cluster_state_bucket}"

  application            = "formbuilderpublisher"
  environment-name       = "${var.environment-name}"
  is-production          = "${var.is-production}"
  infrastructure-support = "${var.infrastructure-support}"
  team_name              = "${var.team_name}"
}

resource "kubernetes_secret" "publisher-elasticache" {
  metadata {
    name      = "elasticache-formbuilder-publisher-dev"
    namespace = "formbuilder-platform-dev"
  }

  data {
    url = "redis://${lookup(module.publisher-elasticache.cache_nodes[0],"address")}:${lookup(module.publisher-elasticache.cache_nodes[0],"port")}"
  }
}

########################################################
