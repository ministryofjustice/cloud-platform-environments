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

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo" {
  metadata {
    name      = "ecr-repo-hmpps-book-secure-move-api"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo.repo_url
  }
}
