module "cccd_claims_submitted" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=3.0"

  team_name          = "laa-get-paid"
  topic_display_name = "cccd-claims-submitted"

  providers = {
    aws = "aws.london"
  }
}

module "claims_for_ccr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.1"

  environment-name       = "staging"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"
  existing_user_name     = "${module.cccd_claims_submitted.user_name}"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ccr_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  providers = {
    aws = "aws.london"
  }
}

resource "aws_sqs_queue_policy" "claims_for_ccr_policy" {
  queue_url = "${module.claims_for_ccr.sqs_id}"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.claims_for_ccr.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.claims_for_ccr.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition": 
            {
              "ArnEquals": 
                {
                  "aws:SourceArn": "${module.cccd_claims_submitted.topic_arn}"
                }
              }
        }
      ]
  }
  EOF
}

module "ccr_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.1"

  environment-name       = "staging"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"
  existing_user_name     = "${module.cccd_claims_submitted.user_name}"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "cccd_claims_submitted" {
  metadata {
    name      = "cccd-messaging"
    namespace = "cccd-staging"
  }

  data {
    access_key_id     = "${module.cccd_claims_submitted.access_key_id}"
    secret_access_key = "${module.cccd_claims_submitted.secret_access_key}"
    topic_arn         = "${module.cccd_claims_submitted.topic_arn}"
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
