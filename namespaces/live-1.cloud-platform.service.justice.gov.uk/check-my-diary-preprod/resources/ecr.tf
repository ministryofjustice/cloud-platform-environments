module "checkmydiary-service" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "check-my-diary"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary_ecr_credentials" {
  metadata {
    name      = "checkmydiary-ecr-credentials-output"
    namespace = "check-my-diary-preprod"
  }

  data {
    access_key_id     = "${module.checkmydiary-service.access_key_id}"
    secret_access_key = "${module.checkmydiary-service.secret_access_key}"
    repo_arn          = "${module.checkmydiary-service.repo_arn}"
    repo_url          = "${module.checkmydiary-service.repo_url}"
  }
}

module "checkmydiary-notification-service" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "check-my-diary-notification-service"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary-notification-service_ecr_credentials" {
  metadata {
    name      = "checkmydiary-notification-service-ecr-credentials-output"
    namespace = "check-my-diary-preprod"
  }

  data {
    access_key_id     = "${module.checkmydiary-notification-service.access_key_id}"
    secret_access_key = "${module.checkmydiary-notification-service.secret_access_key}"
    repo_arn          = "${module.checkmydiary-notification-service.repo_arn}"
    repo_url          = "${module.checkmydiary-notification-service.repo_url}"
  }
}
