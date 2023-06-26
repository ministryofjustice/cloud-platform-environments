resource "aws_sns_topic_subscription" "custody-key-dates-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.custody-key-dates-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "person.prison-identifer.added"
    ]
  })
}

resource "aws_sns_topic_subscription" "custody-key-dates-and-delius-queue-oe-subscription" {
  topic_arn = data.aws_sns_topic.prison-offender-events.arn
  protocol  = "sqs"
  endpoint  = module.custody-key-dates-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "CONFIRMED_RELEASE_DATE-CHANGED",
      "SENTENCE_DATES-CHANGED"
    ]
  })
}

module "custody-key-dates-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "custody-key-dates-and-delius"
  sqs_name    = "custody-key-dates-and-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.custody-key-dates-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "custody-key-dates-and-delius-queue-policy" {
  queue_url = module.custody-key-dates-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "custody-key-dates-and-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "custody-key-dates-and-delius"
  sqs_name    = "custody-key-dates-and-delius-dlq"
}

resource "aws_sqs_queue_policy" "custody-key-dates-and-delius-dlq-policy" {
  queue_url = module.custody-key-dates-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "custody-key-dates-and-delius-queue-secret" {
  metadata {
    name      = "custody-key-dates-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.custody-key-dates-and-delius-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.custody-key-dates-and-delius-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.custody-key-dates-and-delius-queue.secret_access_key
  }
}

module "custody-key-dates-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "custody-key-dates-and-delius"
  role_policy_arns     = { sqs = module.custody-key-dates-and-delius-queue.irsa_policy_arn }
}
