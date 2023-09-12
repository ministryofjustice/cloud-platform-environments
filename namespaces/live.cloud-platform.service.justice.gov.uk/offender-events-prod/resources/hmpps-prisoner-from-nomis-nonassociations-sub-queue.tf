module "prisoner_from_nomis_nonassociations_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "prisoner_from_nomis_nonassociations_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_from_nomis_nonassociations_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

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

resource "aws_sqs_queue_policy" "prisoner_from_nomis_nonassociations_queue_policy" {
  queue_url = module.prisoner_from_nomis_nonassociations_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_from_nomis_nonassociations_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_from_nomis_nonassociations_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.offender_events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner_from_nomis_nonassociations_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prisoner_from_nomis_nonassociations_dl_queue"
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

resource "kubernetes_secret" "prisoner_from_nomis_nonassociations_queue" {
  metadata {
    name      = "prisoner-from-nomis-nonassociations-queue"
    namespace = "hmpps-prisoner-from-nomis-migration-prod"
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_nonassociations_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_nonassociations_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_nonassociations_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_nonassociations_dead_letter_queue" {
  metadata {
    name      = "prisoner-from-nomis-nonassociations-dl-queue"
    namespace = "hmpps-prisoner-from-nomis-migration-prod"
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_nonassociations_dead_letter_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_nonassociations_dead_letter_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_nonassociations_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_nonassociations_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prisoner_from_nomis_nonassociations_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"NON_ASSOCIATION_DETAIL-UPSERTED\",\"NON_ASSOCIATION_DETAIL-DELETED\"]}"
}
