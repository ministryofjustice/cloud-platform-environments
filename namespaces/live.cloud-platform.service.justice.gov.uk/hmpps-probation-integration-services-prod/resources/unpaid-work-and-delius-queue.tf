resource "aws_sns_topic_subscription" "unpaid-work-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.unpaid-work-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["unpaid-work.assessment.completed"]
  })
}

module "unpaid-work-and-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "unpaid-work-and-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.unpaid-work-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "unpaid-work-and-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "unpaid-work-and-delius-queue-policy" {
  queue_url = module.unpaid-work-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "unpaid-work-and-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "unpaid-work-and-delius-dlq"

  # Tags
  business_unit          = var.business_unit
  application            = "unpaid-work-and-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "unpaid-work-and-delius-dlq-policy" {
  queue_url = module.unpaid-work-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "unpaid-work-and-delius-queue-secret" {
  metadata {
    name      = "unpaid-work-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.unpaid-work-and-delius-queue.sqs_name
  }
}

module "unpaid-work-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "unpaid-work-and-delius"
  role_policy_arns     = { sqs = module.unpaid-work-and-delius-queue.irsa_policy_arn }
}
