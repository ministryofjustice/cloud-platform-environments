resource "aws_sns_topic_subscription" "person-search-index-from-delius-contact-queue-subscription" {
  topic_arn = data.aws_sns_topic.probation-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.person-search-index-from-delius-contact-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["CONTACT_CHANGED"]
  })
}

module "person-search-index-from-delius-contact-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "person-search-index-from-delius-contact-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.person-search-index-from-delius-contact-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "person-search-index-from-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-contact-queue-policy" {
  queue_url = module.person-search-index-from-delius-contact-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "person-search-index-from-delius-contact-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "person-search-index-from-delius-contact-dlq"
  message_retention_seconds = 604800 # 1 week

  # Tags
  business_unit          = var.business_unit
  application            = "person-search-index-from-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "person-search-index-from-delius-contact-dlq-policy" {
  queue_url = module.person-search-index-from-delius-contact-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "person-search-index-from-delius-contact-queue-secret" {
  metadata {
    name      = "person-search-index-from-delius-contact-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.person-search-index-from-delius-contact-queue.sqs_name
  }
}

resource "kubernetes_secret" "person-search-index-from-delius-contact-dlq-secret" {
  metadata {
    name      = "person-search-index-from-delius-contact-dlq"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.person-search-index-from-delius-contact-dlq.sqs_name
  }
}

module "person-search-index-from-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "person-search-index-from-delius"
  role_policy_arns = {
    contact-queue = module.person-search-index-from-delius-contact-queue.irsa_policy_arn,
    contact-dlq   = module.person-search-index-from-delius-contact-dlq.irsa_policy_arn,
    person-queue  = module.person-search-index-from-delius-person-queue.irsa_policy_arn,
    person-dlq    = module.person-search-index-from-delius-person-dlq.irsa_policy_arn,
  }
}