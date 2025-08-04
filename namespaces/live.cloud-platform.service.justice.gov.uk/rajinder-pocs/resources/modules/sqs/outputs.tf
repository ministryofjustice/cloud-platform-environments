output "sqs_queue_arn" {
    value = module.queue.sqs_arn
    description = "SQS Queue ARN"
}

output "iam_roles_granted_access" {
    value = local.local.sqs_roles_with_app_tag
    description = "IRSA Roles Granted Access to SQS"
}
