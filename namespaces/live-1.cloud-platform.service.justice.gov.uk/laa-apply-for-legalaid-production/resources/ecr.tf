module "ecr-repo-applyforlegalaid-service" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"

  team_name = "laa-apply-for-legal-aid"
  repo_name = "applyforlegalaid-service"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-applyforlegalaid-service" {
  metadata {
    name      = "ecr-repo-applyforlegalaid-service"
    namespace = "laa-apply-for-legalaid-production"
  }

  data = {
    repo_arn          = module.ecr-repo-applyforlegalaid-service.repo_arn
    repo_url          = module.ecr-repo-applyforlegalaid-service.repo_url
    access_key_id     = module.ecr-repo-applyforlegalaid-service.access_key_id
    secret_access_key = module.ecr-repo-applyforlegalaid-service.secret_access_key
  }
}

module "ecr-repo-clamav" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"

  team_name = "laa-apply-for-legal-aid"
  repo_name = "clamav"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ecr-repo-clamav" {
  metadata {
    name      = "ecr-repo-clamav"
    namespace = "laa-apply-for-legalaid-production"
  }

  data = {
    repo_arn          = module.ecr-repo-clamav.repo_arn
    repo_url          = module.ecr-repo-clamav.repo_url
    access_key_id     = module.ecr-repo-clamav.access_key_id
    secret_access_key = module.ecr-repo-clamav.secret_access_key
  }
}

