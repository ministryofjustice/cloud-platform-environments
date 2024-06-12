/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest versions listed on the
 * releases page of this repository
 *
 */
module "cica_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"
  
  # Repository configuration
  repo_name = "cica-repo-dev"


  # OpenID Connect configuration
  oidc_providers      = ["circleci"]
  github_repositories = var.repo_name

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr_repo" {
  metadata {
    name      = "ecr-credentials-output"
    namespace = "claim-criminal-injuries-compensation-dev"
  }

  data = {
    repo_arn          = module.cica_ecr_credentials.repo_arn
    repo_url          = module.cica_ecr_credentials.repo_url
  }
}

