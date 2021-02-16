module "laa_apply_bot_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "laa-apply-bot"
  team_name = "laa-apply-for-legal-aid"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "laa_apply_bot_ecr_credentials" {
  metadata {
    name      = "ecr-credentials-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.laa_apply_bot_ecr_credentials.access_key_id
    secret_access_key = module.laa_apply_bot_ecr_credentials.secret_access_key
    repo_arn          = module.laa_apply_bot_ecr_credentials.repo_arn
    repo_url          = module.laa_apply_bot_ecr_credentials.repo_url
  }
}
