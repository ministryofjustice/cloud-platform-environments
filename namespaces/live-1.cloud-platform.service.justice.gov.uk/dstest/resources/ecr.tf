module "dstest_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.1"
  repo_name = "dstest"
  team_name = "webops"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dstest_ecr_credentials" {
  metadata {
    name      = "dstest-ecr-credentials"
    namespace = "dstest"
  }

  data = {
    access_key_id     = module.dstest_ecr_credentials.access_key_id
    secret_access_key = module.dstest_ecr_credentials.secret_access_key
    repo_arn          = module.dstest_ecr_credentials.repo_arn
    repo_url          = module.dstest_ecr_credentials.repo_url
  }
}

