/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest versions listed on the
 * releases page of this repository
 *
 */
module "cica_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"

  oidc_providers = ["circleci"]

  github_repositories = [
    "data-capture-service",
    "application-service",
    "gov-uk-notify-gateway",
    "cica-web"
  ]

  namespace = var.namespace

  providers = {
    aws = aws.london
  }
}

