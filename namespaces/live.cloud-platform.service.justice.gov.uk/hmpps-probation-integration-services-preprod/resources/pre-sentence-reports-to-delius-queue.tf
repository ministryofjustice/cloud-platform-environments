resource "aws_sns_topic_subscription" "pre-sentence-reports-to-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.pre-sentence-reports-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["pre-sentence.report.completed"]
  })
}

module "pre-sentence-reports-to-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "pre-sentence-reports-to-delius-queue-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.pre-sentence-reports-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "pre-sentence-reports-to-delius-queue"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "pre-sentence-reports-to-delius-queue-policy" {
  queue_url = module.pre-sentence-reports-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "pre-sentence-reports-to-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "pre-sentence-reports-to-delius-dlq"

  # Tags
  business_unit          = var.business_unit
  application            = "pre-sentence-reports-to-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "pre-sentence-reports-to-delius-dlq-policy" {
  queue_url = module.pre-sentence-reports-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "pre-sentence-reports-to-delius-queue-secret" {
  metadata {
    name      = "pre-sentence-reports-to-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.pre-sentence-reports-to-delius-queue.sqs_name
  }
}

module "pre-sentence-reports-to-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "pre-sentence-reports-to-delius"
  role_policy_arns     = { sqs = module.pre-sentence-reports-to-delius-queue.irsa_policy_arn }
}