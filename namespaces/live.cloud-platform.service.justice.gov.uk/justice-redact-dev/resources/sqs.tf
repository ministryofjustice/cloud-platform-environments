########################################################################
# SQS queue(s) for justice-redact-dev
#
# Purpose: task queue used to schedule document-redaction jobs out to
# k8s pods running the AI/ML redaction models (e.g. consumed by pods
# scaled via KEDA on ApproximateNumberOfMessagesVisible).
#
# Module docs: https://github.com/ministryofjustice/cloud-platform-terraform-sqs
#
# Pinned to ref=5.1.2. Check
# https://github.com/ministryofjustice/cloud-platform-terraform-sqs/releases
# periodically for newer releases and bump deliberately.
########################################################################

# ---------------------------------------------------------------------
# Main task queue
# ---------------------------------------------------------------------
module "redact_task_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "${var.team_name}-${var.environment}-redact-task-queue" # -> <team_name>-<environment_name>-redact-task-queue
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
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.redact_task_queue_dlq.sqs_arn
    maxReceiveCount     = 3
  })


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

  sqs_name        = "${var.team_name}-${var.environment}-redact-task-queue-dlq"
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
# The module itself already creates a scoped IAM policy (sqs:* limited
# to this queue's ARN) and exposes it as irsa_policy_arn - no need to
# hand-roll our own. This gets attached to the shared IRSA role in
# irsa.tf (role_policy_arns), same pattern as module.s3_bucket.irsa_policy_arn.
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# Expose queue details to the FastAPI backend + ML worker pods
#
# The SQS module doesn't create a k8s secret itself (unlike the RDS/S3/
# OpenSearch modules), so we create one here, following the same
# pattern as the existing justice-redact-irsa secret, so the app can
# read the queue URL/ARNs via secretKeyRef instead of hardcoding them.
# ---------------------------------------------------------------------
resource "kubernetes_secret" "redact_task_queue_output" {
  metadata {
    name      = "${var.team_name}-${var.environment}-sqs"
    namespace = var.namespace
    annotations = {
      description = "SQS task queue details for document-redaction jobs (queue_url, queue_arn, queue_name, dlq_arn). Managed by sqs.tf."
    }
  }

  data = {
    queue_url  = module.redact_task_queue.sqs_id
    queue_arn  = module.redact_task_queue.sqs_arn
    queue_name = module.redact_task_queue.sqs_name
    dlq_arn    = module.redact_task_queue_dlq.sqs_arn
  }
}

resource "aws_cloudwatch_metric_alarm" "redact_task_queue_age" {
  alarm_name = "${module.redact_task_queue.sqs_name}-oldest-message-age"

  alarm_description = "Justice Redact document processing messages have been waiting for more than 10 minutes; owned by ${var.team_name}"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateAgeOfOldestMessage"

  dimensions = {
    QueueName = module.redact_task_queue.sqs_name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 600
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "redact_task_queue_depth" {
  alarm_name = "${module.redact_task_queue.sqs_name}-visible-messages"

  alarm_description = "Justice Redact document processing queue has more than 5 waiting messages; owned by ${var.team_name}"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = module.redact_task_queue.sqs_name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "redact_task_queue_dlq_depth" {
  alarm_name = "${module.redact_task_queue_dlq.sqs_name}-visible-messages"

  alarm_description = "Justice Redact document processing DLQ contains messages requiring investigation; owned by ${var.team_name}"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = module.redact_task_queue_dlq.sqs_name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
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

# ---------------------------------------------------------------------
# Apply Redactions queue
# ---------------------------------------------------------------------

module "apply_redactions_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name         = "${var.team_name}-${var.environment}-apply-redactions-queue"
  encrypt_sqs_kms  = "true"

  visibility_timeout_seconds = 900
  receive_wait_time_seconds   = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.apply_redactions_queue_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


# ---------------------------------------------------------------------
# Apply Redactions dead letter queue
# ---------------------------------------------------------------------

module "apply_redactions_queue_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "${var.team_name}-${var.environment}-apply-redactions-queue-dlq"
  encrypt_sqs_kms = "true"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


# ---------------------------------------------------------------------
# Expose Apply Redactions queue details to Kubernetes
# ---------------------------------------------------------------------

resource "kubernetes_secret" "apply_redactions_queue_output" {
  metadata {
    name      = "${var.team_name}-${var.environment}-redaction-sqs"
    namespace = var.namespace

    annotations = {
      description = "SQS queue details for Apply Redactions processing. Managed by sqs.tf."
    }
  }

  data = {
    queue_url  = module.apply_redactions_queue.sqs_id
    queue_arn  = module.apply_redactions_queue.sqs_arn
    queue_name = module.apply_redactions_queue.sqs_name
    dlq_arn    = module.apply_redactions_queue_dlq.sqs_arn
  }
}


# ---------------------------------------------------------------------
# Apply Redactions queue monitoring
# ---------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "apply_redactions_queue_age" {
  alarm_name = "${module.apply_redactions_queue.sqs_name}-oldest-message-age"

  alarm_description = "Justice Redact Apply Redactions messages have been waiting for more than 10 minutes; owned by ${var.team_name}"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateAgeOfOldestMessage"

  dimensions = {
    QueueName = module.apply_redactions_queue.sqs_name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 600
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "apply_redactions_queue_depth" {
  alarm_name = "${module.apply_redactions_queue.sqs_name}-visible-messages"

  alarm_description = "Justice Redact Apply Redactions queue has more than 5 waiting messages; owned by ${var.team_name}"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = module.apply_redactions_queue.sqs_name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "apply_redactions_queue_dlq_depth" {
  alarm_name = "${module.apply_redactions_queue_dlq.sqs_name}-visible-messages"

  alarm_description = "Justice Redact Apply Redactions DLQ contains messages requiring investigation; owned by ${var.team_name}"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = module.apply_redactions_queue_dlq.sqs_name
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}


# ---------------------------------------------------------------------
# Apply Redactions queue outputs
# ---------------------------------------------------------------------

output "apply_redactions_queue_url" {
  description = "URL of the SQS queue used to schedule Apply Redactions processing"
  value       = module.apply_redactions_queue.sqs_id
}

output "apply_redactions_queue_arn" {
  description = "ARN of the SQS queue used to schedule Apply Redactions processing"
  value       = module.apply_redactions_queue.sqs_arn
}

output "apply_redactions_queue_dlq_arn" {
  description = "ARN of the dead-letter queue for failed Apply Redactions processing"
  value       = module.apply_redactions_queue_dlq.sqs_arn
}
