##########################################
# Parliamentary Questions ECR repository #
##########################################

module "pq_ecr_credentials" {
  repo_name = var.repo_name
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.3.0"
  team_name = var.team_name

  providers = {
    aws = aws.london
  }

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = [var.repo_name]

  # set your namespace name to create a ConfigMap
  # of credentials you need in CircleCI
  namespace = var.namespace


}

resource "kubernetes_secret" "pq_ecr_credentials" {
  metadata {
    name      = "pq-ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.pq_ecr_credentials.access_key_id
    repo_arn          = module.pq_ecr_credentials.repo_arn
    repo_url          = module.pq_ecr_credentials.repo_url
    secret_access_key = module.pq_ecr_credentials.secret_access_key
  }
}

resource "kubernetes_secret" "pq_ecr_credentials_production" {
  metadata {
    name      = "pq-ecr-credentials-output"
    namespace = "parliamentary-questions-production"
  }

  data = {
    access_key_id     = module.pq_ecr_credentials.access_key_id
    repo_arn          = module.pq_ecr_credentials.repo_arn
    repo_url          = module.pq_ecr_credentials.repo_url
    secret_access_key = module.pq_ecr_credentials.secret_access_key
  }
}
