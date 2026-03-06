module "domain_events_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name              = "domain_events_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.domain_events_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-ims" # team name is used in queue name so setting to hard coded value
  environment_name       = var.environment-name
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
}

module "domain_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "domain_events_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-ims" # team name is used in queue name so setting to hard coded value
  environment_name       = var.environment-name
  namespace              = var.namespace
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "domain_events_queue_secret" {
  metadata {
    name      = "domain-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.domain_events_queue.sqs_id
    queue_arn  = module.domain_events_queue.sqs_arn
    queue_name = module.domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "domain_events_dlq_secret" {
  metadata {
    name      = "domain-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.domain_events_dlq.sqs_id
    queue_arn  = module.domain_events_dlq.sqs_arn
    queue_name = module.domain_events_dlq.sqs_name
  }
}

resource "aws_sns_topic_subscription" "domain_events_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.merged"
    ]
  })
}

resource "aws_sqs_queue_policy" "domain_events_queue_policy" {
  queue_url = module.domain_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}