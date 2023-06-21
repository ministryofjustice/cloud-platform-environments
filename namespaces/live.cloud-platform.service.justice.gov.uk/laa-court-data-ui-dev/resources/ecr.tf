module "lcdui_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"
  team_name = var.team_name
  repo_name = var.repo_name

  providers = {
    aws = aws.london
  }

  oidc_providers      = ["github"]
  github_repositories = ["laa-court-data-ui"]
  namespace           = var.namespace
}

resource "kubernetes_secret" "lcdui_ecr_credentials" {
  metadata {
    name      = "lcdui-ecr-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.lcdui_ecr_credentials.access_key_id
    secret_access_key = module.lcdui_ecr_credentials.secret_access_key
    repo_arn          = module.lcdui_ecr_credentials.repo_arn
    repo_url          = module.lcdui_ecr_credentials.repo_url
  }
}
