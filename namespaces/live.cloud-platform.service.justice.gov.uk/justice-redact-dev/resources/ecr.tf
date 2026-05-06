/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.1.0"

  # Repository configuration
  repo_name = var.justice-redact-dev

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = ["example-repository"]

  # Tags
  business_unit          = var.OCTO
  application            = var.justice_redact
  is_production          = var.is_production
  team_name              = var.JusticeRedactTeam # also used for naming the container repository
  namespace              = var.justice-redact-dev # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for read only queries,
  # uncomment below:

  # enable_irsa = true
}
