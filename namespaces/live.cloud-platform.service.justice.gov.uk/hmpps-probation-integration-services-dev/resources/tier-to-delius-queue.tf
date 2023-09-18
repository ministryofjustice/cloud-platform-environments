resource "aws_sns_topic_subscription" "tier-to-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.tier-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["tier.calculation.complete"]
  })
}

module "tier-to-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "tier-to-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.tier-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "tier-to-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "tier-to-delius-queue-policy" {
  queue_url = module.tier-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "tier-to-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "tier-to-delius-dlq"

  # Tags
  business_unit          = var.business_unit
  application            = "tier-to-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "tier-to-delius-dlq-policy" {
  queue_url = module.tier-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "tier-to-delius-queue-secret" {
  metadata {
    name      = "tier-to-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.tier-to-delius-queue.sqs_name
  }
}

module "tier-to-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "tier-to-delius"
  role_policy_arns     = { sqs = module.tier-to-delius-queue.irsa_policy_arn }
}
