/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "track_a_query_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  repo_name = "track-a-query-ecr" # Arbitrary module name does not need to reference any existing modules
  team_name = var.team_name

  providers = {
    aws = aws.london
  }

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = ["correspondence_tool_staff"]

  # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace
 
}

resource "kubernetes_secret" "track_a_query_ecr_credentials" {
  metadata {
    name      = "track-a-query-ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.track_a_query_ecr_credentials.access_key_id
    secret_access_key = module.track_a_query_ecr_credentials.secret_access_key
    repo_arn          = module.track_a_query_ecr_credentials.repo_arn
    repo_url          = module.track_a_query_ecr_credentials.repo_url
  }
}
