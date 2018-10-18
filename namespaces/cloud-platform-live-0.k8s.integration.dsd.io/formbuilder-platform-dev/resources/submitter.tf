##################################################
# Publisher RDS

module "submitter-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=2.1"

  cluster_name               = "${var.cluster_name}"
  cluster_state_bucket       = "${var.cluster_state_bucket}"
  db_backup_retention_period = "2"
  application                = "formbuildersubmitter"
  environment-name           = "${var.environment-name}"
  is-production              = "${var.is-production}"
  infrastructure-support     = "${var.infrastructure-support}"
  team_name                  = "${var.team_name}"
}

resource "kubernetes_secret" "submitter-rds-instance" {
  metadata {
    name      = "rds-instance-formbuilder-submitter-dev"
    namespace = "formbuilder-platform-dev"
  }

  data {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.submitter-rds-instance.database_username}:${module.submitter-rds-instance.database_password}@${module.submitter-rds-instance.rds_instance_endpoint}/${module.submitter-rds-instance.database_name}"
  }
}

##################################################

########################################################
# Publisher Elasticache Redis (for resque + job logging)
module "submitter-elasticache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=2.0"

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
    name      = "elasticache-formbuilder-submitter-dev"
    namespace = "formbuilder-platform-dev"
  }

  data {
    primary_endpoint_address = "${module.submitter-elasticache.primary_endpoint_address}"
    auth_token               = "${module.submitter-elasticache.auth_token}"
  }
}

########################################################

# Submitter ECR Repos
module "ecr-repo-fb-submitter-base" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-submitter-base"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-fb-submitter-base"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-submitter-base.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-submitter-base.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-submitter-base.secret_access_key}"
  }
}

module "ecr-repo-fb-submitter-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-submitter-api"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-fb-submitter-api"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-submitter-api.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-submitter-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-submitter-api.secret_access_key}"
  }
}

module "ecr-repo-fb-submitter-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-submitter-worker"
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-fb-submitter-worker"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-submitter-worker.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-submitter-worker.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-submitter-worker.secret_access_key}"
  }
}
