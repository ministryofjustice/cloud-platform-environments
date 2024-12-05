module "ecr-repo-datasette" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = "ecr-repo-datasette"

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

resource "kubernetes_secret" "ecr-repo-datasette" {
  metadata {
    name      = "ecr-repo-hmpps-book-secure-move-datasette"
    namespace = var.namespace
  }

  data = {
    repo_url = module.ecr-repo-datasette.repo_url
  }
}
