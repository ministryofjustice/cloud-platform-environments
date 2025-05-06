resource "aws_sns_topic_subscription" "person-search-index-from-delius-contact-keyword-queue-subscription" {
  topic_arn = data.aws_sns_topic.probation-offender-events-prod.arn
  protocol  = "sqs"
  endpoint  = module.person-search-index-from-delius-contact-keyword-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "CONTACT_CHANGED",
      "CONTACT_DELETED"
    ]
  })
}

module "person-search-index-from-delius-contact-keyword-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name      = "person-search-index-from-delius-contact-keyword-queue"
  delay_seconds = 5

  # Tags
  application            = "person-search-index-from-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-contact-keyword-queue-policy" {
  queue_url = module.person-search-index-from-delius-contact-keyword-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "person-search-index-from-delius-contact-keyword-queue-secret" {
  metadata {
    name      = "person-search-index-from-delius-contact-keyword-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.person-search-index-from-delius-contact-keyword-queue.sqs_name
  }
}
