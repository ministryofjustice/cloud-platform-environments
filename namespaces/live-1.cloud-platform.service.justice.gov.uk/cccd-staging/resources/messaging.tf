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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=iam-policies"

  environment-name       = "staging"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"

  providers = {
    aws = "aws.london"
  }
}

module "ccr_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=iam-policies"

  environment-name       = "staging"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"
  existing_user_name     = "${module.claims_for_ccr.user_name}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd-sqs" {
  metadata {
    name      = "cccd-sqs"
    namespace = "cccd-staging"
  }

  data {
    access_key_id     = "${module.claims_for_ccr.access_key_id}"
    secret_access_key = "${module.claims_for_ccr.secret_access_key}"
    sqs_ccr_id        = "${module.claims_for_ccr.sqs_id}"
    sqs_ccr_arn       = "${module.claims_for_ccr.sqs_arn}"
    sqs_dlq_id        = "${module.ccr_dead_letter_queue.sqs_id}"
    sqs_dlq_arn       = "${module.ccr_dead_letter_queue.sqs_arn}"
  }
}

resource "aws_sns_topic_subscription" "ccr-queue-subscription" {
  provider      = "aws.london"
  topic_arn     = "${module.cccd_claims_submitted.topic_arn}"
  protocol      = "sqs"
  endpoint      = "${module.claims_for_ccr.sqs_arn}"
  filter_policy = "{\"claim_type\": [\"Claim::AdvocateClaim\", \"Claim::AdvocateInterimClaim\", \"Claim::AdvocateSupplementaryClaim\"]}"
}
