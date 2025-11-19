module "prisoner_from_nomis_courtsentencing_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "prisoner_from_nomis_courtsentencing_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_from_nomis_courtsentencing_dead_letter_queue.sqs_arn
    maxReceiveCount     = 10
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

resource "aws_sqs_queue_policy" "prisoner_from_nomis_courtsentencing_queue_policy" {
  queue_url = module.prisoner_from_nomis_courtsentencing_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_from_nomis_courtsentencing_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_from_nomis_courtsentencing_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": [
                              "${data.aws_ssm_parameter.offender-events-topic-arn.value}",
                              "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
                            ]
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner_from_nomis_courtsentencing_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "prisoner_from_nomis_courtsentencing_dl_queue"
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

resource "kubernetes_secret" "prisoner_from_nomis_courtsentencing_queue" {
  metadata {
    name      = "prison-events-courtsentencing-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_courtsentencing_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_courtsentencing_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_courtsentencing_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_courtsentencing_dead_letter_queue" {
  metadata {
    name      = "prison-events-courtsentencing-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_courtsentencing_dead_letter_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_courtsentencing_dead_letter_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_courtsentencing_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_courtsentencing_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_from_nomis_courtsentencing_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_CASES-INSERTED",
      "OFFENDER_CASES-UPDATED",
      "OFFENDER_CASES-DELETED",
      "OFFENDER_CASES-LINKED",
      "OFFENDER_CASES-UNLINKED",
      "COURT_EVENTS-INSERTED",
      "COURT_EVENTS-DELETED",
      "COURT_EVENTS-UPDATED",
      "COURT_EVENT_CHARGES-INSERTED",
      "COURT_EVENT_CHARGES-DELETED",
      "COURT_EVENT_CHARGES-UPDATED",
      "COURT_EVENT_CHARGES-LINKED",
      "OFFENDER_CHARGES-UPDATED",
      "OFFENDER_CASE_IDENTIFIERS-DELETED",
      "OFFENDER_CASE_IDENTIFIERS-INSERTED",
      "OFFENDER_CASE_IDENTIFIERS-UPDATED",
      "OFFENDER_SENTENCES-INSERTED",
      "OFFENDER_SENTENCES-DELETED",
      "OFFENDER_SENTENCES-UPDATED",
      "OFFENDER_SENTENCE_TERMS-INSERTED",
      "OFFENDER_SENTENCE_TERMS-DELETED",
      "OFFENDER_SENTENCE_TERMS-UPDATED",
      "OFFENDER_SENTENCE_CHARGES-DELETED",
      "OFFENDER_FIXED_TERM_RECALLS-UPDATED",
    ]
  })
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_domain_courtsentencing_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_from_nomis_courtsentencing_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.merged"
    ]
  })
}
