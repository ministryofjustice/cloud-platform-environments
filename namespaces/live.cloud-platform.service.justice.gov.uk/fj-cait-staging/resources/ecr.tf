module "ecr-repo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  repo_name = var.repo_name

  oidc_providers      = ["github"]
  github_repositories = [var.repo_name]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-fj-cait"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo.repo_url
    repo_arn = module.ecr-repo.repo_arn
  }
}
