/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "intranet_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"
  repo_name = "intranet-ecr" # Arbitrary module name does not need to reference any existing modules
  team_name = var.team_name    # Github team name

  providers = {
    aws = aws.london
  }
  github_repositories = [var.repo_name]

  # enable the oidc implementation for GitHub
  oidc_providers = ["github"]

  # specify which GitHub repository you're pushing from
  github_repositories = [var.app_repo]
}

resource "kubernetes_secret" "intranet_ecr_credentials" {
  metadata {
    name      = "intranet-ecr-credentials-output"
    namespace = "intranet-production"
  }

  data = {
    access_key_id     = module.intranet_ecr_credentials.access_key_id
    secret_access_key = module.intranet_ecr_credentials.secret_access_key
    repo_arn          = module.intranet_ecr_credentials.repo_arn
    repo_url          = module.intranet_ecr_credentials.repo_url
  }
}