# Publisher ECR Repos

module "ecr-repo-fb-publisher-base" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-publisher-base"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-base" {
  metadata {
    name      = "ecr-repo-fb-publisher-base"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-base.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-base.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-base.secret_access_key}"
  }
}

module "ecr-repo-fb-publisher-web" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-publisher-web"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-web" {
  metadata {
    name      = "ecr-repo-fb-publisher-web"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-publisher-web.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-publisher-web.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-publisher-web.secret_access_key}"
  }
}

module "ecr-repo-fb-publisher-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-publisher-worker"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-publisher-worker" {
  metadata {
    name      = "ecr-repo-fb-publisher-worker"
    namespace = "formbuilder-repos"
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-runner-node"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-runner-node" {
  metadata {
    name      = "ecr-repo-fb-runner-node"
    namespace = "formbuilder-repos"
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-service-token-cache"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-service-token-cache" {
  metadata {
    name      = "ecr-repo-fb-service-token-cache"
    namespace = "formbuilder-repos"
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-submitter-base"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-base" {
  metadata {
    name      = "ecr-repo-fb-submitter-base"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-submitter-base.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-submitter-base.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-submitter-base.secret_access_key}"
  }
}

module "ecr-repo-fb-submitter-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-submitter-api"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-api" {
  metadata {
    name      = "ecr-repo-fb-submitter-api"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-submitter-api.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-submitter-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-submitter-api.secret_access_key}"
  }
}

module "ecr-repo-fb-submitter-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-submitter-worker"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-submitter-worke" {
  metadata {
    name      = "ecr-repo-fb-submitter-worker"
    namespace = "formbuilder-repos"
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-user-datastore-api"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-user-datastore-api" {
  metadata {
    name      = "ecr-repo-fb-user-datastore-api"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-user-datastore-api.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-user-datastore-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-user-datastore-api.secret_access_key}"
  }
}

##################################################

# User Filestore ECR Repos
module "ecr-repo-fb-user-filestore-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-user-filestore-api"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-user-filestore-api" {
  metadata {
    name      = "ecr-repo-fb-user-filestore-api"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-user-filestore-api.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-user-filestore-api.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-user-filestore-api.secret_access_key}"
  }
}

##################################################

# AV (Anti Virus) ECR Repos
module "ecr-repo-fb-av" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-av"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-av" {
  metadata {
    name      = "ecr-repo-fb-av"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-av.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-av.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-av.secret_access_key}"
  }
}

##################################################

# fb-builder - docker image used to build form builder components
module "ecr-repo-fb-builder" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-builder"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "ecr-repo-fb-builder" {
  metadata {
    name      = "ecr-repo-fb-builder"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-builder.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-builder.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-builder.secret_access_key}"
  }
}

##################################################

# fb-runner-init-containers - docker image used to initialise runner containers
module "ecr-repo-fb-runner-init-containers" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-runner-init-containers"
}

resource "kubernetes_secret" "ecr-repo-fb-runner-init-containers" {
  metadata {
    name      = "ecr-repo-fb-runner-init-containers"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-runner-init-containers.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-runner-init-containers.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-runner-init-containers.secret_access_key}"
  }
}

##################################################

module "ecr-repo-fb-pdf-generator" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "formbuilder"
  repo_name = "fb-pdf-generator"
}

resource "kubernetes_secret" "ecr-repo-fb-pdf-generator" {
  metadata {
    name      = "ecr-repo-fb-pdf-generator"
    namespace = "formbuilder-repos"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-pdf-generator.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-pdf-generator.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-pdf-generator.secret_access_key}"
  }
}
