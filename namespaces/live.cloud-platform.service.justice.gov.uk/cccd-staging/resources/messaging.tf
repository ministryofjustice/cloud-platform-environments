module "cccd_claims_submitted" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "cccd-claims-submitted"


  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "claims_for_ccr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "cccd-claims-for-ccr"
  encrypt_sqs_kms = "false"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ccr_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "claims_for_ccr_policy" {
  queue_url = module.claims_for_ccr.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.claims_for_ccr.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "CCLFPolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::140455166311:role/LAA-CCR-uat-AppInfrastructureTemplate-1-AppEc2Role-11WILONUECEUX"
              ]
          },
          "Resource": "${module.claims_for_ccr.sqs_arn}",
          "Action": "sqs:*"
        },
        {
          "Sid": "CCCDPolicy",
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

module "claims_for_cclf" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "cccd-claims-for-cclf"
  encrypt_sqs_kms = "false"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cclf_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "claims_for_cclf_policy" {
  queue_url = module.claims_for_cclf.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.claims_for_cclf.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "CCLFPolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::140455166311:role/LAA-CCLF-uat-AppInfrastructureTemplate-AppEc2Role-S3C0S7HVQQBV"
              ]
          },
          "Resource": "${module.claims_for_cclf.sqs_arn}",
          "Action": "sqs:*"
        },
        {
          "Sid": "CCCDPolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.claims_for_cclf.sqs_arn}",
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

module "responses_for_cccd" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "responses-for-cccd"
  encrypt_sqs_kms = "false"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cccd_response_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "responses_for_cccd" {
  queue_url = module.responses_for_cccd.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.responses_for_cccd.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "LandingZonePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::140455166311:role/LAA-CCLF-uat-AppInfrastructureTemplate-AppEc2Role-S3C0S7HVQQBV",
            "arn:aws:iam::140455166311:role/LAA-CCR-uat-AppInfrastructureTemplate-1-AppEc2Role-11WILONUECEUX"
              ]
          },
          "Resource": "${module.responses_for_cccd.sqs_arn}",
          "Action": "sqs:SendMessage"
        }
      ]
  }

EOF

}

module "ccr_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "cccd-claims-submitted-ccr-dlq"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "cclf_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "cccd-claims-submitted-cclf-dlq"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "cccd_response_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "reponses-for-cccd-dlq"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "cccd_claims_submitted" {
  metadata {
    name      = "cccd-messaging"
    namespace = "cccd-staging"
  }

  data = {
    topic_arn         = module.cccd_claims_submitted.topic_arn
    sqs_ccr_name      = module.claims_for_ccr.sqs_name
    sqs_ccr_url       = module.claims_for_ccr.sqs_id
    sqs_ccr_arn       = module.claims_for_ccr.sqs_arn
    sqs_ccr_dlq_name  = module.ccr_dead_letter_queue.sqs_name
    sqs_ccr_dlq_url   = module.ccr_dead_letter_queue.sqs_id
    sqs_ccr_dlq_arn   = module.ccr_dead_letter_queue.sqs_arn
    sqs_cclf_name     = module.claims_for_cclf.sqs_name
    sqs_cclf_url      = module.claims_for_cclf.sqs_id
    sqs_cclf_arn      = module.claims_for_cclf.sqs_arn
    sqs_cclf_dlq_name = module.cclf_dead_letter_queue.sqs_name
    sqs_cclf_dlq_url  = module.cclf_dead_letter_queue.sqs_id
    sqs_cclf_dlq_arn  = module.cclf_dead_letter_queue.sqs_arn
    sqs_cccd_name     = module.responses_for_cccd.sqs_name
    sqs_cccd_url      = module.responses_for_cccd.sqs_id
    sqs_cccd_arn      = module.responses_for_cccd.sqs_arn
    sqs_cccd_dlq_name = module.cccd_response_dead_letter_queue.sqs_name
    sqs_cccd_dlq_url  = module.cccd_response_dead_letter_queue.sqs_id
    sqs_cccd_dlq_arn  = module.cccd_response_dead_letter_queue.sqs_arn
  }
}

resource "aws_sns_topic_subscription" "ccr-queue-subscription" {
  provider      = aws.london
  topic_arn     = module.cccd_claims_submitted.topic_arn
  protocol      = "sqs"
  endpoint      = module.claims_for_ccr.sqs_arn
  filter_policy = "{\"claim_type\": [\"Claim::AdvocateClaim\", \"Claim::AdvocateInterimClaim\", \"Claim::AdvocateSupplementaryClaim\"]}"
}

resource "aws_sns_topic_subscription" "cclf-queue-subscription" {
  provider      = aws.london
  topic_arn     = module.cccd_claims_submitted.topic_arn
  protocol      = "sqs"
  endpoint      = module.claims_for_cclf.sqs_arn
  filter_policy = "{\"claim_type\": [\"Claim::LitigatorClaim\", \"Claim::InterimClaim\", \"Claim::TransferClaim\", \"Claim::LitigatorHardshipClaim\"]}"
}
