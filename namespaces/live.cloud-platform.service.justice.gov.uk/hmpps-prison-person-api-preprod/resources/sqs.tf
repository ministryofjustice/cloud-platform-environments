resource "aws_sns_topic_subscription" "domain_events_queue_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.domain-events-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.merged",
    ]
  })
}

module "domain-events-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "prison_person_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.domain-events-dlq.sqs_arn
    maxReceiveCount     = 3
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

resource "aws_sqs_queue_policy" "domain-events-queue-policy" {
  queue_url = module.domain-events-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.domain-events-queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.domain-events-queue.sqs_arn}",
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

module "domain-events-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prison_person_domain_events_dl"
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

resource "kubernetes_secret" "domain-events-queue" {
  metadata {
    name      = "sqs-domain-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.domain-events-queue.sqs_id
    sqs_queue_arn  = module.domain-events-queue.sqs_arn
    sqs_queue_name = module.domain-events-queue.sqs_name
  }
}

resource "kubernetes_secret" "domain-events-dlq" {
  metadata {
    name      = "sqs-domain-events-queue-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.domain-events-dlq.sqs_id
    sqs_queue_arn  = module.domain-events-dlq.sqs_arn
    sqs_queue_name = module.domain-events-dlq.sqs_name
  }
}
