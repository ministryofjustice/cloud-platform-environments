module "prisoner_from_nomis_csip_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "prisoner_from_nomis_csip_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_from_nomis_csip_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prisoner_from_nomis_csip_queue_policy" {
  queue_url = module.prisoner_from_nomis_csip_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_from_nomis_csip_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_from_nomis_csip_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.offender-events-topic-arn.value}"
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner_from_nomis_csip_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prisoner_from_nomis_csip_dl_queue"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_csip_queue" {
  metadata {
    name      = "prisoner-from-nomis-csip-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_csip_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_csip_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_csip_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_csip_dead_letter_queue" {
  metadata {
    name      = "prisoner-from-nomis-csip-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_csip_dead_letter_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_csip_dead_letter_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_csip_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_csip_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_from_nomis_csip_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "CSIP_REPORTS-INSERTED",
      "CSIP_REPORTS-UPDATED",
      "CSIP_REPORTS-DELETED",
      "CSIP_PLANS-INSERTED",
      "CSIP_PLANS-UPDATED",
      "CSIP_PLANS-DELETED",
      "CSIP_REVIEWS-INSERTED",
      "CSIP_REVIEWS-UPDATED",
      "CSIP_REVIEWS-DELETED",
      "CSIP_ATTENDEES-INSERTED",
      "CSIP_ATTENDEES-UPDATED",
      "CSIP_ATTENDEES-DELETED",
      "CSIP_FACTORS-INSERTED",
      "CSIP_FACTORS-UPDATED",
      "CSIP_FACTORS-DELETED",
      "CSIP_INTVW-INSERTED",
      "CSIP_INTVW-UPDATED",
      "CSIP_INTVW-DELETED",
    ]
  })
}
