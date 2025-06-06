module "delete_oldsnapshots" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.1" # use the latest release

  # Repository configuration
  repo_name = "delete-oldsnapshots"

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["cloud-platform-delete-oldsnapshots"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
