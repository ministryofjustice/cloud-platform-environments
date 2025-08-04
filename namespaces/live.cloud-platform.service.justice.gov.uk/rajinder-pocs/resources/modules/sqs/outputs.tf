output "sqs_queue_arn" {
  value       = module.queue.sqs_arn
  description = "SQS Queue ARN"
}

output "iam_roles_granted_access" {
  value       = local.sqs_roles_with_app_tag
  description = "IRSA Roles Granted Access to SQS"
}

output "irsa_policy_arn" {
  value       = module.queue.irsa_policy_arn
  description = "IRSA Policy ARN for SQS Queue"
}