module "ecr-repo-allocation-manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = "offender-management-allocation-manager"

  deletion_protection = false

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-allocation-manager-production" {
  metadata {
    name      = "ecr-repo-allocation-manager"
    namespace = "offender-management-production"
  }

  data = {
    repo_url = module.ecr-repo-allocation-manager.repo_url
  }
}
