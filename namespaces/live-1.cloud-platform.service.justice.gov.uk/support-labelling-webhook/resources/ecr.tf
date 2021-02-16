module "ecr-repo-support-labelling" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"

  team_name = "webops"
  repo_name = "support-labelling-webhooks"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-api" {
  metadata {
    name      = "ecr-support-labelling-webhook"
    namespace = "support-labelling-webhook"
  }

  data = {
    repo_url          = module.ecr-repo-support-labelling.repo_url
    access_key_id     = module.ecr-repo-support-labelling.access_key_id
    secret_access_key = module.ecr-repo-support-labelling.secret_access_key
  }
}

