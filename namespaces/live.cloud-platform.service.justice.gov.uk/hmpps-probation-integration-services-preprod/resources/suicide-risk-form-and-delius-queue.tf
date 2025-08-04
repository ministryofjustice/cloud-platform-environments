resource "aws_sns_topic_subscription" "suicide-risk-form-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.suicide-risk-form-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["probation-case.suicide-risk-form.created", "probation-case.suicide-risk-form.deleted"]
  })
}

module "suicide-risk-form-and-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "suicide-risk-form-and-delius-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.suicide-risk-form-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "suicide-risk-form-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "suicide-risk-form-and-delius-queue-policy" {
  queue_url = module.suicide-risk-form-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "suicide-risk-form-and-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "suicide-risk-form-and-delius-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "suicide-risk-form-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "suicide-risk-form-and-delius-dlq-policy" {
  queue_url = module.suicide-risk-form-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "suicide-risk-form-and-delius-queue-secret" {
  metadata {
    name      = "suicide-risk-form-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.suicide-risk-form-and-delius-queue.sqs_name
  }
}

module "suicide-risk-form-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "suicide-risk-form-and-delius"
  role_policy_arns     = { sqs = module.suicide-risk-form-and-delius-queue.irsa_policy_arn }
}
