resource "aws_sns_topic_subscription" "domain_events" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.domain_events_topic_arn.value
  protocol  = "sqs"
  endpoint  = module.domain_events_sqs_queue.sqs_arn

  filter_policy = jsonencode({
    eventType = [
      "offender-management.noop",
      "prisoner-offender-search.prisoner.updated",
      "probation-case.registration.added",
      "probation-case.registration.deleted",
      "probation-case.registration.deregistered",
      "probation-case.registration.updated",
      "tier.calculation.complete"
    ]
  })
}

resource "aws_sns_topic_subscription" "probation_events" {
  provider  = aws.london
  topic_arn = data.aws_sns_topic.probation_events_topic.arn
  protocol  = "sqs"
  endpoint  = module.domain_events_sqs_queue.sqs_arn

  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_MANAGER_CHANGED",
      "OFFENDER_OFFICER_CHANGED",
      "OFFENDER_DETAILS_CHANGED"
    ]
  })
}

module "domain_events_sqs_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "domain-events"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.domain_events_sqs_dlq.sqs_arn
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

resource "aws_sqs_queue_policy" "domain_events_sqs_queue_policy" {
  queue_url = module.domain_events_sqs_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.domain_events_sqs_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.domain_events_sqs_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": [
                              "${data.aws_ssm_parameter.domain_events_topic_arn.value}",
                              "${data.aws_sns_topic.probation_events_topic.arn}"
                            ]
                          }
                        }
        }
      ]
  }
EOF

}

module "domain_events_sqs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "domain-events-dlq"
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

resource "kubernetes_secret" "domain_events" {
  metadata {
    name      = "domain-events"
    namespace = var.namespace
  }

  data = {
    DOMAIN_EVENTS_SQS_QUEUE_URL  = module.domain_events_sqs_queue.sqs_id
    DOMAIN_EVENTS_SQS_QUEUE_ARN  = module.domain_events_sqs_queue.sqs_arn
    DOMAIN_EVENTS_SQS_QUEUE_NAME = module.domain_events_sqs_queue.sqs_name
    DOMAIN_EVENTS_SQS_DLQ_URL    = module.domain_events_sqs_dlq.sqs_id
    DOMAIN_EVENTS_SQS_DLQ_ARN    = module.domain_events_sqs_dlq.sqs_arn
    DOMAIN_EVENTS_SQS_DLQ_NAME   = module.domain_events_sqs_dlq.sqs_name
  }
}

data "aws_ssm_parameter" "domain_events_topic_arn" {
  name = "/hmpps-domain-events-preprod/topic-arn"
}

data "aws_sns_topic" "probation_events_topic" {
  name = "cloud-platform-Digital-Prison-Services-dbe10e8d9c1f4d100f0c723d5d9b754e"
}
