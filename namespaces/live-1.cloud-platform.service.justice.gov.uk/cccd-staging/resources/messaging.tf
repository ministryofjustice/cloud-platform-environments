module "cccd_claims_submitted" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=2.0"

  team_name          = "laa-get-paid"
  topic_display_name = "cccd-claims-submitted"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd_claims_submitted" {
  metadata {
    name      = "cccd-claims-submitted-sns"
    namespace = "cccd-staging"
  }

  data {
    access_key_id     = "${module.cccd_claims_submitted.access_key_id}"
    secret_access_key = "${module.cccd_claims_submitted.secret_access_key}"
    topic_arn         = "${module.cccd_claims_submitted.topic_arn}"
  }
}

module "claims_for_ccr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=2.0"

  environment-name       = "dev"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "claims_for_ccr" {
  metadata {
    name      = "claims-for-ccr-sqs"
    namespace = "cccd-dev"
  }

  data {
    access_key_id     = "${module.claims_for_ccr.access_key_id}"
    secret_access_key = "${module.claims_for_ccr.secret_access_key}"
    sqs_id            = "${module.claims_for_ccr.sqs_id}"
    sqs_arn           = "${module.claims_for_ccr.sqs_arn}"
  }
}

resource "aws_sns_topic_subscription" "ccr-queue-subscription" {
  provider      = "aws.sns2sqs"
  topic_arn     = "${module.cccd_claims_submitted.topic_arn}"
  protocol      = "sqs"
  endpoint      = "${module.claims_for_ccr.sqs_arn}"
  filter_policy = "[\"Claim::AdvocateClaim\", \"Claim::AdvocateInterimClaim\", \"Claim::AdvocateSupplementaryClaim\"]"
}
