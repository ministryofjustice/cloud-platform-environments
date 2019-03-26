# NB. although this lives in the dev namespace these repos are used by dev, staging and production
########################################################

# Publisher ECR Repos

module "ecr-repo-fb-publisher-base" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-publisher-base"
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-base" {
  metadata {
    name      = "ecr-repo-fb-publisher-base"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-base.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-base.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-base.secret_access_key}"
  }
}

module "ecr-repo-fb-publisher-web" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-publisher-web"
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-web" {
  metadata {
    name      = "ecr-repo-fb-publisher-web"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-web.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-web.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-web.secret_access_key}"
  }
}

module "ecr-repo-fb-publisher-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-publisher-worker"
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-worker" {
  metadata {
    name      = "ecr-repo-fb-publisher-worker"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-worker.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-worker.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-worker.secret_access_key}"
  }
}

##################################################

# Runner ECR Repos
module "ecr-repo-fb-runner-node" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-runner-node"
}

resource "kubernetes_secret" "ecr-repo-fb-runner-node" {
  metadata {
    name      = "ecr-repo-fb-runner-node"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-runner-node.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-runner-node.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-runner-node.secret_access_key}"
  }
}

########################################################

# Service Token Cache ECR Repos
module "ecr-repo-fb-service-token-cache" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-service-token-cache"
}

resource "kubernetes_secret" "ecr-repo-fb-service-token-cache" {
  metadata {
    name      = "ecr-repo-fb-service-token-cache"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-service-token-cache.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-service-token-cache.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-service-token-cache.secret_access_key}"
  }
}

########################################################

# Submitter ECR Repos
module "ecr-repo-fb-submitter-base" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-submitter-base"
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-base" {
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-submitter-api"
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-api" {
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-submitter-worker"
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-worke" {
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

##################################################

# User Datastore ECR Repos
module "ecr-repo-fb-user-datastore-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"

  team_name = "${var.team_name}"
  repo_name = "fb-user-datastore-api"
}

resource "kubernetes_secret" "ecr-repo-fb-user-datastore-api" {
  metadata {
    name      = "ecr-repo-fb-user-datastore-api"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-user-datastore-api.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-user-datastore-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-user-datastore-api.secret_access_key}"
  }
}
