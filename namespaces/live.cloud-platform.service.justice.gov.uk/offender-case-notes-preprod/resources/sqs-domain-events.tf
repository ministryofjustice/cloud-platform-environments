module "case_notes_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  sqs_name                  = "case_notes_domain_events_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.case_notes_domain_events_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "case_notes_domain_events_queue_policy" {
  queue_url = module.case_notes_domain_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "case_notes_domain_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  sqs_name        = "case_notes_domain_events_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sns_topic_subscription" "case_notes_domain_events_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.case_notes_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.merged",
      "person.alert.created",
      "person.alert.inactive"
    ]
  })
}


resource "kubernetes_secret" "case_notes_domain_events_queue_secret" {
  metadata {
    name      = "domain-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.case_notes_domain_events_queue.sqs_id
    queue_arn  = module.case_notes_domain_events_queue.sqs_arn
    queue_name = module.case_notes_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "case_notes_domain_events_queue_secret_dlq" {
  metadata {
    name      = "domain-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.case_notes_domain_events_dlq.sqs_id
    queue_arn  = module.case_notes_domain_events_dlq.sqs_arn
    queue_name = module.case_notes_domain_events_dlq.sqs_name
  }
}