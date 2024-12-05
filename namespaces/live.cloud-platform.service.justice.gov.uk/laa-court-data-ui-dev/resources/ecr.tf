module "lcdui_ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  repo_name = var.repo_name

  oidc_providers      = ["circleci"]
  github_repositories = ["laa-court-data-ui"]

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

resource "kubernetes_secret" "lcdui_ecr_credentials" {
  metadata {
    name      = "lcdui-ecr-credentials"
    namespace = var.namespace
  }

  data = {
    repo_arn = module.lcdui_ecr_credentials.repo_arn
    repo_url = module.lcdui_ecr_credentials.repo_url
  }
}
