module "ecr-repo-estatesdb-dev" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "estatesdb-dev"
  team_name = "programmeandperformance"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-estatesdb-dev" {
  metadata {
    name      = "ecr-repo-estatesdb-dev"
    namespace = "estatesdb-dev"
  }

  data = {
    access_key_id     = module.ecr-repo-estatesdb-dev.access_key_id
    secret_access_key = module.ecr-repo-estatesdb-dev.secret_access_key
    repo_arn          = module.ecr-repo-estatesdb-dev.repo_arn
    repo_url          = module.ecr-repo-estatesdb-dev.repo_url
  }
}
