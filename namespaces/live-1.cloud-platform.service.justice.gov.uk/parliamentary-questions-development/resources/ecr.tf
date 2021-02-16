##########################################
# Parliamentary Questions ECR repository #
##########################################

module "pq_ecr_credentials" {
  repo_name = var.repo_name
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  team_name = var.team_name

  providers = {
    aws = aws.london
  }
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
