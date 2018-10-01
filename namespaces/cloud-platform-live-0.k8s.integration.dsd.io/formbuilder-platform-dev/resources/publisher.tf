##################################################
# Publisher RDS

module "publisher-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=2.1"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  db_backup_retention_period = "2"
  application                = "formbuilderpublisher"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
}

resource "kubernetes_secret" "publisher-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-publisher-dev"
    namespace = "formbuilder-platform-dev"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.publisher-rds-instance.database_username}:${module.publisher-rds-instance.database_password}@${module.publisher-rds-instance.rds_instance_endpoint}/${module.publisher-rds-instance.database_name}"
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

