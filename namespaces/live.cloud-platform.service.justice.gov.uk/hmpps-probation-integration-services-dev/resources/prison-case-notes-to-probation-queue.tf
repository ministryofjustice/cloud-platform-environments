resource "aws_sns_topic_subscription" "prison-case-notes-to-probation-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.prison-case-notes-to-probation-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["prison.case-note.published"],
    caseNoteType = [
      "PRISON-RELEASE",
      "TRANSFER-FROMTOL",
      "GEN-OSE",
      "ALERT-ACTIVE",
      "ALERT-INACTIVE",
      { prefix = "OMIC" },
      { prefix = "OMIC_OPD" },
      { prefix = "KA" }
    ]
  })
}

module "prison-case-notes-to-probation-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "prison-case-notes-to-probation-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prison-case-notes-to-probation-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "prison-case-notes-to-probation"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "prison-case-notes-to-probation-queue-policy" {
  queue_url = module.prison-case-notes-to-probation-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "prison-case-notes-to-probation-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "prison-case-notes-to-probation-dlq"

  # Tags
  business_unit          = var.business_unit
  application            = "prison-case-notes-to-probation"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "prison-case-notes-to-probation-dlq-policy" {
  queue_url = module.prison-case-notes-to-probation-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "prison-case-notes-to-probation-queue-secret" {
  metadata {
    name      = "prison-case-notes-to-probation-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.prison-case-notes-to-probation-queue.sqs_name
  }
}

module "prison-case-notes-to-probation-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "prison-case-notes-to-probation"
  role_policy_arns     = { sqs = module.prison-case-notes-to-probation-queue.irsa_policy_arn }
}
