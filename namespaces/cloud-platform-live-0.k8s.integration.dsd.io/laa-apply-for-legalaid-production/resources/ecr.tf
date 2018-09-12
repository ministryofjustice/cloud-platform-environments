terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr-repo-provider-frontend" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=master"

  team_name = "apply-for-legalaid"
  repo_name = "provider-frontend"
}

resource "kubernetes_secret" "ecr-repo-provider-frontend" {
  metadata {
    name      = "ecr-repo-provider-frontend"
    namespace = "laa-apply-for-legalaid-production"
  }

  data {
    repo_url          = "${module.ecr-repo-provider-frontend.repo_url}"
    access_key_id     = "${module.ecr-repo-provider-frontend.access_key_id}"
    secret_access_key = "${module.ecr-repo-provider-frontend.secret_access_key}"
  }
}

module "ecr-repo-citizen-frontend" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=master"

  team_name = "apply-for-legalaid"
  repo_name = "citizen-frontend"
}

resource "kubernetes_secret" "ecr-repo-citizen-frontend" {
  metadata {
    name      = "ecr-repo-citizen-frontend"
    namespace = "laa-apply-for-legalaid-production"
  }

  data {
    repo_url          = "${module.ecr-repo-citizen-frontend.repo_url}"
    access_key_id     = "${module.ecr-repo-citizen-frontend.access_key_id}"
    secret_access_key = "${module.ecr-repo-citizen-frontend.secret_access_key}"
  }
}

module "ecr-repo-applyforlegalaid-service" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=master"

  team_name = "apply-for-legalaid"
  repo_name = "applyforlegalaid-service"
}

resource "kubernetes_secret" "ecr-repo-applyforlegalaid-service" {
  metadata {
    name      = "ecr-repo-applyforlegalaid-service"
    namespace = "laa-apply-for-legalaid-production"
  }

  data {
    repo_url          = "${module.ecr-repo-applyforlegalaid-service.repo_url}"
    access_key_id     = "${module.ecr-repo-applyforlegalaid-service.access_key_id}"
    secret_access_key = "${module.ecr-repo-applyforlegalaid-service.secret_access_key}"
  }
}
