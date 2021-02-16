module "checkmydiary-service-dev" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "check-my-diary-dev"
  team_name = "check-my-diary"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "checkmydiary_ecr_credentials" {
  metadata {
    name      = "checkmydiary-ecr-credentials-output"
    namespace = "check-my-diary-dev"
  }

  data = {
    access_key_id     = module.checkmydiary-service-dev.access_key_id
    secret_access_key = module.checkmydiary-service-dev.secret_access_key
    repo_arn          = module.checkmydiary-service-dev.repo_arn
    repo_url          = module.checkmydiary-service-dev.repo_url
  }
}

module "checkmydiary-notification-service-dev" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "check-my-diary-notification-service-dev"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary-notification-service_ecr_credentials" {
  metadata {
    name      = "checkmydiary-notification-service-ecr-credentials-output"
    namespace = "check-my-diary-dev"
  }

  data = {
    access_key_id     = module.checkmydiary-notification-service-dev.access_key_id
    secret_access_key = module.checkmydiary-notification-service-dev.secret_access_key
    repo_arn          = module.checkmydiary-notification-service-dev.repo_arn
    repo_url          = module.checkmydiary-notification-service-dev.repo_url
  }
}

