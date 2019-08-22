module "cccd_claims_submitted" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=3.0"

  team_name          = "${var.team_name}"
  topic_display_name = "cccd-claims-submitted"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd_claims_submitted" {
  metadata {
    name      = "cccd-messaging"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.cccd_claims_submitted.access_key_id}"
    secret_access_key = "${module.cccd_claims_submitted.secret_access_key}"
    topic_arn         = "${module.cccd_claims_submitted.topic_arn}"
  }
}
