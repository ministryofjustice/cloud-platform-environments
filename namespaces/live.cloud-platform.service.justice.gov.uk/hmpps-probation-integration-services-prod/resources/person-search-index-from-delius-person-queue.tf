resource "aws_sns_topic_subscription" "person-search-index-from-delius-person-queue-subscription" {
  topic_arn = data.aws_sns_topic.probation-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.person-search-index-from-delius-person-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_CHANGED",
      "OFFENDER_MANAGER_CHANGED",
      "OFFENDER_REGISTRATION_CHANGED",
      "OFFENDER_REGISTRATION_DEREGISTERED",
      "OFFENDER_REGISTRATION_DELETED",
      "SENTENCE_CHANGED",
      "CONVICTION_CHANGED"
    ]
  })
}

module "person-search-index-from-delius-person-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "person-search-index-from-delius-person-queue"

  # Tags
  application            = "person-search-index-from-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-person-queue-policy" {
  queue_url = module.person-search-index-from-delius-person-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "person-search-index-from-delius-person-queue-secret" {
  metadata {
    name      = "person-search-index-from-delius-person-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.person-search-index-from-delius-person-queue.sqs_name
  }
}
