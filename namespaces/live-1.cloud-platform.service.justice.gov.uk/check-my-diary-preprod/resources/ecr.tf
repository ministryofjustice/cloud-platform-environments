module "checkmydiary-service-preprod" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "check-my-diary-preprod"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary_ecr_credentials" {
  metadata {
    name      = "checkmydiary-ecr-credentials-output"
    namespace = "check-my-diary-preprod"
  }

  data {
    access_key_id     = "${module.checkmydiary-service-preprod.access_key_id}"
    secret_access_key = "${module.checkmydiary-service-preprod.secret_access_key}"
    repo_arn          = "${module.checkmydiary-service-preprod.repo_arn}"
    repo_url          = "${module.checkmydiary-service-preprod.repo_url}"
  }
}

module "checkmydiary-notification-service-preprod" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "check-my-diary-notification-service-preprod"
  team_name = "check-my-diary"
}

resource "kubernetes_secret" "checkmydiary-notification-service_ecr_credentials" {
  metadata {
    name      = "checkmydiary-notification-service-ecr-credentials-output"
    namespace = "check-my-diary-preprod"
  }

  data {
    access_key_id     = "${module.checkmydiary-notification-service-preprod.access_key_id}"
    secret_access_key = "${module.checkmydiary-notification-service-preprod.secret_access_key}"
    repo_arn          = "${module.checkmydiary-notification-service-preprod.repo_arn}"
    repo_url          = "${module.checkmydiary-notification-service-preprod.repo_url}"
  }
}
