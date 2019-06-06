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

  environment-name       = "staging"
  team_name              = "laa-get-paid"
  infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
  application            = "cccd"

  policy = <<EOF
{
  "Policy": 
  {
    "Version": "2012-10-17",
    "Id": "${module.claims_for_ccr.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Action": "SQS:SendMessage",
          "Resource": "${module.claims_for_ccr.sqs_arn}",
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
}

EOF

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "claims_for_ccr" {
  metadata {
    name      = "claims-for-ccr-sqs"
    namespace = "cccd-staging"
  }

  data {
    access_key_id     = "${module.claims_for_ccr.access_key_id}"
    secret_access_key = "${module.claims_for_ccr.secret_access_key}"
    sqs_id            = "${module.claims_for_ccr.sqs_id}"
    sqs_arn           = "${module.claims_for_ccr.sqs_arn}"
  }
}

resource "aws_sns_topic_subscription" "ccr-queue-subscription" {
  provider      = "aws.london"
  topic_arn     = "${module.cccd_claims_submitted.topic_arn}"
  protocol      = "sqs"
  endpoint      = "${module.claims_for_ccr.sqs_arn}"
  filter_policy = "{\"claim_type\": [\"Claim::AdvocateClaim\", \"Claim::AdvocateInterimClaim\", \"Claim::AdvocateSupplementaryClaim\"]}"
}
