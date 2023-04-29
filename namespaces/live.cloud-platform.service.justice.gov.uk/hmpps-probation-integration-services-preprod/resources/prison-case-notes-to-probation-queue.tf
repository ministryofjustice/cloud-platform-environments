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
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "prison-case-notes-to-probation"
  sqs_name    = "prison-case-notes-to-probation-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prison-case-notes-to-probation-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "prison-case-notes-to-probation-queue-policy" {
  queue_url = module.prison-case-notes-to-probation-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "prison-case-notes-to-probation-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "prison-case-notes-to-probation"
  sqs_name    = "prison-case-notes-to-probation-dlq"
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
    QUEUE_NAME            = module.prison-case-notes-to-probation-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.prison-case-notes-to-probation-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.prison-case-notes-to-probation-queue.secret_access_key
  }
}
