module "live0_to_live1_migration_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=1.0"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  aws_region             = "${var.aws_region}"
}

resource "kubernetes_secret" "live0_to_live1_migration_sqs" {
  metadata {
    name      = "live0-to-live1-migration-sqs"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.live0_to_live1_migration_sqs.access_key_id}"
    secret_access_key = "${module.live0_to_live1_migration_sqs.secret_access_key}"
    sqs_id            = "${module.live0_to_live1_migration_sqs.sqs_id}"
    sqs_arn           = "${module.live0_to_live1_migration_sqs.sqs_arn}"
  }
}
