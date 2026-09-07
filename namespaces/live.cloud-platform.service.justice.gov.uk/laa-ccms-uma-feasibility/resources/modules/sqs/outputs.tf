output "sqs_queue_arn" {
  value       = module.queue.sqs_arn
  description = "SQS Queue ARN"
}

output "sqs_dlq_arn" {
  value       = module.dlq.sqs_arn
  description = "SQS Dead Letter Queue ARN"
}

output "queue_irsa_policy_arn" {
  value       = module.queue.irsa_policy_arn
  description = "IRSA Policy ARN for SQS Queue"
}

output "dlq_irsa_policy_arn" {
  value       = module.dlq.irsa_policy_arn
  description = "IRSA Policy ARN for DLQ"
}

output "iam_roles_granted_access" {
  value       = local.sqs_roles_with_namespace_tag
  description = "IRSA Roles Granted Access to SQS"
}
