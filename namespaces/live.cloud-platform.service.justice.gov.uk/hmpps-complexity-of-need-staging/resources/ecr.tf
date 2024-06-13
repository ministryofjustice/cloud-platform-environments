module "ecr-repo-complexity-of-need" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"

  team_name = var.team_name
  repo_name = "hmpps-complexity-of-need"

  # Tags
  business_unit          = "HMPPS"
  application            = "hmpps-complexity-of-need"
  is_production          = "false"
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = "manage-pom-cases@digital.justice.gov.uk"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-complexity-of-need" {
  metadata {
    name      = "ecr-repo-complexity-of-need"
    namespace = "hmpps-complexity-of-need-staging"
  }

  data = {
    repo_url = module.ecr-repo-complexity-of-need.repo_url
  }
}
