
module "temp_cccd_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.6"
  repo_name = "cccd-temp"
  team_name = "laa-get-paid"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "temp_cccd_ecr_credentials" {
  metadata {
    name      = "temp-cccd-ecr-credentials-output"
    namespace = "cccd-dev"
  }

  data = {
    access_key_id     = module.temp_cccd_ecr_credentials.access_key_id
    secret_access_key = module.temp_cccd_ecr_credentials.secret_access_key
    repo_arn          = module.temp_cccd_ecr_credentials.repo_arn
    repo_url          = module.temp_cccd_ecr_credentials.repo_url
  }
}
