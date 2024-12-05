# HMCTS Complaints Adapter ECR Repos
module "ecr-repo-hmcts-complaints-adapter" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = "hmcts-complaints-formbuilder-adapter"

  # Tags
  business_unit          = "Platforms"
  application            = "hmcts-complaints-formbuilder-adapter"
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "ecr-repo-hmcts-complaints-adapter" {
  metadata {
    name      = "ecr-repo-hmcts-complaints-adapter"
    namespace = "hmcts-complaints-formbuilder-adapter-${var.environment-name}"
  }

  data = {
    repo_url = module.ecr-repo-hmcts-complaints-adapter.repo_url
  }
}
