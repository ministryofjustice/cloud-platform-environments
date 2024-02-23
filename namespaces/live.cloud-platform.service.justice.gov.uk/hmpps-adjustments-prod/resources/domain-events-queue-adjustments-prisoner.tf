module "hmpps_adjustments_prisoner_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "hmpps_adjustments_prisoner_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_adjustments_prisoner_dead_letter_queue.sqs_arn
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

resource "aws_sqs_queue_policy" "hmpps_adjustments_prisoner_queue_policy" {
  queue_url = module.hmpps_adjustments_prisoner_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_adjustments_prisoner_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_adjustments_prisoner_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
              {
                "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
              }
            }
        }
      ]
  }
EOF
}

module "hmpps_adjustments_prisoner_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "hmpps_adjustments_prisoner_dlq"
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

resource "kubernetes_secret" "hmpps_adjustments_prisoner_queue" {
  metadata {
    name      = "sqs-adjustments-prisoner-events-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_adjustments_prisoner_queue.sqs_id
    sqs_queue_arn  = module.hmpps_adjustments_prisoner_queue.sqs_arn
    sqs_queue_name = module.hmpps_adjustments_prisoner_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_adjustments_prisoner_dead_letter_queue" {
  metadata {
    name      = "sqs-adjustments-prisoner-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_adjustments_prisoner_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_adjustments_prisoner_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_adjustments_prisoner_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_adjustments_prisoner_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_adjustments_prisoner_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prisoner-offender-search.prisoner.released",
      "prisoner-offender-search.prisoner.received"
    ]
  })
}
