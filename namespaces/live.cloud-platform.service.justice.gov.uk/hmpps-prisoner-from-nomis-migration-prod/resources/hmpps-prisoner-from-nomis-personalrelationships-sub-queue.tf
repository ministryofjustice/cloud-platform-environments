module "prisoner_from_nomis_personalrelationships_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "prisoner_from_nomis_personalrelationships_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_from_nomis_personalrelationships_dead_letter_queue.sqs_arn
    maxReceiveCount     = 5
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prisoner_from_nomis_personalrelationships_queue_policy" {
  queue_url = module.prisoner_from_nomis_personalrelationships_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_from_nomis_personalrelationships_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_from_nomis_personalrelationships_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": [
                              "${data.aws_ssm_parameter.offender-events-topic-arn.value}"
                            ]
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner_from_nomis_personalrelationships_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "prisoner_from_nomis_personalrelationships_dl_queue"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_personalrelationships_queue" {
  metadata {
    name      = "prison-events-personalrelationships-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_personalrelationships_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_personalrelationships_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_personalrelationships_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_personalrelationships_dead_letter_queue" {
  metadata {
    name      = "prison-events-personalrelationships-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_personalrelationships_dead_letter_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_personalrelationships_dead_letter_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_personalrelationships_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_personalrelationships_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_from_nomis_personalrelationships_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "PERSON-INSERTED",
      "PERSON-UPDATED",
      "PERSON-DELETED",
      "ADDRESSES_PERSON-INSERTED",
      "ADDRESSES_PERSON-UPDATED",
      "ADDRESSES_PERSON-DELETED",
      "PHONES_PERSON-INSERTED",
      "PHONES_PERSON-UPDATED",
      "PHONES_PERSON-DELETED",
      "INTERNET_ADDRESSES_PERSON-INSERTED",
      "INTERNET_ADDRESSES_PERSON-UPDATED",
      "INTERNET_ADDRESSES_PERSON-DELETED",
      "VISITOR_RESTRICTION-UPSERTED",
      "VISITOR_RESTRICTION-DELETED",
      "OFFENDER_CONTACT-INSERTED",
      "OFFENDER_CONTACT-UPDATED",
      "OFFENDER_CONTACT-DELETED",
      "PERSON_RESTRICTION-UPSERTED",
      "PERSON_RESTRICTION-DELETED",
      "PERSON_EMPLOYMENTS-INSERTED",
      "PERSON_EMPLOYMENTS-UPDATED",
      "PERSON_EMPLOYMENTS-DELETED",
      "PERSON_IDENTIFIERS-INSERTED",
      "PERSON_IDENTIFIERS-UPDATED",
      "PERSON_IDENTIFIERS-DELETED",
      "OFFENDER_PHYSICAL_DETAILS-CHANGED",
      "RESTRICTION-UPSERTED",
      "RESTRICTION-DELETED",
      "BOOKING-DELETED"
    ]
  })
}

