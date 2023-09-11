module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  repo_name = var.namespace

  oidc_providers = ["circleci"]

  # specify which GitHub repository you're pushing from
  github_repositories = ["HMCTS-iacfees"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.ecr.repo_arn
    repo_url = module.ecr.repo_url
  }
}
