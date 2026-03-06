module "prisoner_from_nomis_organisations_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "prisoner_from_nomis_organisations_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_from_nomis_organisations_dead_letter_queue.sqs_arn
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

resource "aws_sqs_queue_policy" "prisoner_from_nomis_organisations_queue_policy" {
  queue_url = module.prisoner_from_nomis_organisations_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_from_nomis_organisations_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_from_nomis_organisations_queue.sqs_arn}",
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

module "prisoner_from_nomis_organisations_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "prisoner_from_nomis_organisations_dl_queue"
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

resource "kubernetes_secret" "prisoner_from_nomis_organisations_queue" {
  metadata {
    name      = "prison-events-organisations-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_organisations_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_organisations_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_organisations_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_organisations_dead_letter_queue" {
  metadata {
    name      = "prison-events-organisations-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_organisations_dead_letter_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_organisations_dead_letter_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_organisations_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_organisations_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_from_nomis_organisations_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "CORPORATE-INSERTED",
      "CORPORATE-UPDATED",
      "CORPORATE-DELETED",
      "ADDRESSES_CORPORATE-INSERTED",
      "ADDRESSES_CORPORATE-UPDATED",
      "ADDRESSES_CORPORATE-DELETED",
      "PHONES_CORPORATE-INSERTED",
      "PHONES_CORPORATE-UPDATED",
      "PHONES_CORPORATE-DELETED",
      "INTERNET_ADDRESSES_CORPORATE-INSERTED",
      "INTERNET_ADDRESSES_CORPORATE-UPDATED",
      "INTERNET_ADDRESSES_CORPORATE-DELETED",
      "CORPORATE_TYPES-INSERTED",
      "CORPORATE_TYPES-UPDATED",
      "CORPORATE_TYPES-DELETED",
    ]
  })
}

