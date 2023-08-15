module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"

  oidc_providers = ["circleci"]

  github_repositories = ["fb-deploy"]

  namespace = var.namespace
}
