##################################################
# Publisher RDS
module "user-datastore-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=2.1"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  db_backup_retention_period = "2"
  application                = "formbuilderuserdatastore"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
}

resource "kubernetes_secret" "user-datastore-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-user-datastore-staging"
    namespace = "formbuilder-platform-staging"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.publisher-rds-instance.database_username}:${module.publisher-rds-instance.database_password}@${module.publisher-rds-instance.rds_instance_endpoint}/${module.publisher-rds-instance.database_name}"
  }
}

##################################################

# User Datastore ECR Repos
module "ecr-repo-fb-user-datastore-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-user-datastore-api"
}

resource "kubernetes_secret" "ecr-repo-fb-user-datastore-api" {
  metadata {
    name      = "ecr-repo-fb-user-datastore-api"
    namespace = "formbuilder-platform-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-user-datastore-api.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-user-datastore-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-user-datastore-api.secret_access_key}"
  }
}
