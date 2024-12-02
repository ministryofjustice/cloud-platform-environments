#################################
# C100 Application ECR repository
#################################

module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = var.repo_name

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = ["c100-application"]

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-c100"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo.repo_url
  }
}
