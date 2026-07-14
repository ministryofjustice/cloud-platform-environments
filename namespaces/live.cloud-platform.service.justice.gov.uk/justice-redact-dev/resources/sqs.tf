########################################################################
# SQS queue(s) for justice-redact-dev
#
# Purpose: task queue used to schedule document-redaction jobs out to
# k8s pods running the AI/ML redaction models (e.g. consumed by pods
# scaled via KEDA on ApproximateNumberOfMessagesVisible).
#
# Module docs: https://github.com/ministryofjustice/cloud-platform-terraform-sqs
#
########################################################################

# ---------------------------------------------------------------------
# Main task queue
# ---------------------------------------------------------------------
module "redact_task_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "redact-task-queue" # -> <team_name>-<environment_name>-redact-task-queue
  encrypt_sqs_kms = "true"

  # Long enough that an in-flight ML job isn't picked up by a second pod
  # before the first one finishes. Set to comfortably more than your
  # worst-case model runtime (AWS recommend ~6x average processing time).
  visibility_timeout_seconds = 900 # 15 min - adjust to match actual model runtime

  # Long polling - pods polling the queue wait up to 20s for a message
  # rather than hammering the API with empty receives.
  receive_wait_time_seconds = 20

  # Redrive policy - send failed/poison messages to the DLQ below.
  # Kept low since retrying an expensive ML task repeatedly wastes
  # compute if the underlying document is the problem.
  redrive_policy = <<EOF
{
  "deadLetterTargetArn": "${module.redact_task_queue_dlq.sqs_arn}",
  "maxReceiveCount": 2
}
EOF

  # Tags (standard Cloud Platform tagging variables, defined in resources/variables.tf)
  business_unit           = var.business_unit
  application             = var.application
  is_production           = var.is_production
  team_name                = var.team_name
  namespace                = var.namespace
  environment_name          = var.environment
  infrastructure_support    = var.infrastructure_support
}

# ---------------------------------------------------------------------
# Dead letter queue - failed redaction tasks land here for investigation
# ---------------------------------------------------------------------
module "redact_task_queue_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "redact-task-queue-dlq"
  encrypt_sqs_kms = "true"

  business_unit           = var.business_unit
  application             = var.application
  is_production           = var.is_production
  team_name                = var.team_name
  namespace                = var.namespace
  environment_name          = var.environment
  infrastructure_support    = var.infrastructure_support
}

# ---------------------------------------------------------------------
# IAM access for the redaction pods
#
# Both the FastAPI backend (producer) and the ML worker pods (consumer)
# run under the same IRSA role (see irsa.tf: service_account_name =
# "${var.team_name}-${var.environment}"), so this is a single
# identity-based policy covering both send and receive/delete, rather
# than a resource-based queue policy. No aws_sqs_queue_policy needed -
# same-account access is governed entirely by this IAM policy once it's
# attached to the IRSA role below.
# ---------------------------------------------------------------------
data "aws_iam_policy_document" "redact_task_queue_access" {
  statement {
    sid    = "RedactTaskQueueAccess"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",       # FastAPI backend enqueues redaction tasks
      "sqs:ReceiveMessage",    # ML worker pods poll for tasks
      "sqs:DeleteMessage",     # ML worker pods ack completed tasks
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = [module.redact_task_queue.sqs_arn]
  }
}

resource "aws_iam_policy" "redact_task_queue_access" {
  name   = "${var.namespace}-redact-task-queue-access"
  policy = data.aws_iam_policy_document.redact_task_queue_access.json

  tags = {
    business-unit          = var.business_unit
    application             = var.application
    is-production           = var.is_production
    environment-name        = var.environment
    owner                   = var.team_name
    infrastructure-support  = var.infrastructure_support
  }
}

# ---------------------------------------------------------------------
# Outputs - handy for wiring up a KEDA ScaledObject / TriggerAuthentication
# if the ML worker pods are autoscaled off queue depth
# (ApproximateNumberOfMessagesVisible), and for the app's own config.
# ---------------------------------------------------------------------
output "redact_task_queue_url" {
  description = "URL of the SQS queue used to schedule document-redaction tasks to the ML worker pods"
  value       = module.redact_task_queue.sqs_id
}

output "redact_task_queue_arn" {
  description = "ARN of the SQS queue used to schedule document-redaction tasks to the ML worker pods"
  value       = module.redact_task_queue.sqs_arn
}

output "redact_task_queue_dlq_arn" {
  description = "ARN of the dead-letter queue for failed document-redaction tasks"
  value       = module.redact_task_queue_dlq.sqs_arn
}