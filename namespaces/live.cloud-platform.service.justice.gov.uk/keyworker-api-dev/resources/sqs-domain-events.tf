module "keyworker_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  sqs_name                  = "keyworker_domain_events_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.keyworker_domain_events_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "keyworker_domain_events_queue_policy" {
  queue_url = module.keyworker_domain_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "keyworker_domain_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  sqs_name        = "keyworker_domain_events_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sns_topic_subscription" "keyworker_domain_events_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.keyworker_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    "$or" : [
      {
        eventType = [
          "complexity-of-need.level.changed",
          "prison-offender-events.prisoner.merged"
        ]
      },
      {
        eventType = [
          "person.case-note.created",
          "person.case-note.updated",
          "person.case-note.moved",
          "person.case-note.deleted"
        ],
        type = [
          "KA"
        ]
      }
    ]
  })
}


resource "kubernetes_secret" "keyworker_domain_events_queue_secret" {
  metadata {
    name      = "domain-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.keyworker_domain_events_queue.sqs_id
    queue_arn  = module.keyworker_domain_events_queue.sqs_arn
    queue_name = module.keyworker_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "keyworker_domain_events_queue_secret_dlq" {
  metadata {
    name      = "domain-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.keyworker_domain_events_dlq.sqs_id
    queue_arn  = module.keyworker_domain_events_dlq.sqs_arn
    queue_name = module.keyworker_domain_events_dlq.sqs_name
  }
}
