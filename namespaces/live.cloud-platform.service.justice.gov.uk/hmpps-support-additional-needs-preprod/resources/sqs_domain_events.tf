module "hmpps_san_domain_events_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                  = "san_domain_events_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_san_domain_events_dlq.sqs_arn
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

resource "aws_sqs_queue_policy" "hmpps_san_domain_events_queue_policy" {
  queue_url = module.hmpps_san_domain_events_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "hmpps_san_domain_events_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "san_domain_events_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sns_topic_subscription" "hmpps_san_domain_events_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_san_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.received",
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.merged",
      "prison.education.updated",
      "prison.education-aln-assessment.updated"
    ]
  })
}


resource "kubernetes_secret" "hmpps_san_domain_events_queue_secret" {
  metadata {
    name      = "hmpps-support-additional-needs-domain-events-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_san_domain_events_queue.sqs_id
    sqs_queue_arn  = module.hmpps_san_domain_events_queue.sqs_arn
    sqs_queue_name = module.hmpps_san_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_san_domain_events_queue_secret_dlq" {
  metadata {
    name      = "hmpps-support-additional-needs-domain-events-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_san_domain_events_dlq.sqs_id
    sqs_queue_arn  = module.hmpps_san_domain_events_dlq.sqs_arn
    sqs_queue_name = module.hmpps_san_domain_events_dlq.sqs_name
  }
}
