/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "alfresco-content-ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  # Repository configuration
  repo_name = "alfresco-content-repository"

  # OpenID Connect configuration
  oidc_providers        = ["github"]
  github_repositories   = ["hmpps-alfresco","hmpps-delius-alfresco-poc"]
  github_actions_prefix = "content"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "alfresco-share-ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.1.0"

  # Repository configuration
  repo_name = "alfresco-share"

  # OpenID Connect configuration
  oidc_providers        = ["github"]
  github_repositories   = ["hmpps-delius-alfresco-poc"]
  github_actions_prefix = "share"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
