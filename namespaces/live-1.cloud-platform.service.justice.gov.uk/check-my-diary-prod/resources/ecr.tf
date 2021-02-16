module "checkmydiary-service-prod" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "check-my-diary-prod"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary_ecr_credentials" {
  metadata {
    name      = "checkmydiary-ecr-credentials-output"
    namespace = "check-my-diary-prod"
  }

  data = {
    access_key_id     = module.checkmydiary-service-prod.access_key_id
    secret_access_key = module.checkmydiary-service-prod.secret_access_key
    repo_arn          = module.checkmydiary-service-prod.repo_arn
    repo_url          = module.checkmydiary-service-prod.repo_url
  }
}

module "checkmydiary-notification-service-prod" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "check-my-diary-notification-service-prod"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary-notification-service_ecr_credentials" {
  metadata {
    name      = "checkmydiary-notification-service-ecr-credentials-output"
    namespace = "check-my-diary-prod"
  }

  data = {
    access_key_id     = module.checkmydiary-notification-service-prod.access_key_id
    secret_access_key = module.checkmydiary-notification-service-prod.secret_access_key
    repo_arn          = module.checkmydiary-notification-service-prod.repo_arn
    repo_url          = module.checkmydiary-notification-service-prod.repo_url
  }
}

