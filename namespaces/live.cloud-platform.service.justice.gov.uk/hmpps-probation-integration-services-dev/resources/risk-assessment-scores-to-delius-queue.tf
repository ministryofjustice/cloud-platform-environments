resource "aws_sns_topic_subscription" "risk-assessment-scores-to-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.risk-assessment-scores-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["risk-assessment.scores.determined"]
  })
}

module "risk-assessment-scores-to-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "risk-assessment-scores-to-delius"
  sqs_name    = "risk-assessment-scores-to-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.risk-assessment-scores-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "risk-assessment-scores-to-delius-queue-policy" {
  queue_url = module.risk-assessment-scores-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "risk-assessment-scores-to-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "risk-assessment-scores-to-delius"
  sqs_name    = "risk-assessment-scores-to-delius-dlq"
}

resource "aws_sqs_queue_policy" "risk-assessment-scores-to-delius-dlq-policy" {
  queue_url = module.risk-assessment-scores-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "risk-assessment-scores-to-delius-queue-secret" {
  metadata {
    name      = "risk-assessment-scores-to-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.risk-assessment-scores-to-delius-queue.sqs_name
  }
}

module "risk-assessment-scores-to-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "risk-assessment-scores-to-delius"
  role_policy_arns     = { sqs = module.risk-assessment-scores-to-delius-queue.irsa_policy_arn }
}
