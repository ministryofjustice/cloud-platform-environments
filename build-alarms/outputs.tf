output "notify_slack_lambda_function_version" {
  description = "Latest published version of your Lambda function"
  value       = "${aws_lambda_function.notify_slack.arn}"
}

output "notify_cloudwatch_rule" {
  description = "Name of your Cloudwatch rule"
  value       = "${aws_cloudwatch_event_rule.codebuild_watcher_rule.name}"
}

output "notify_lambda_permissions" {
  description = "Permissions ARN for Lambda"
  value       = "${aws_iam_role.cp_build_LambdaExecution.arn}"
}

output "notify_lambda_execution_IAM_ID" {
  description = "IAM Lambda Role ID"
  value       = "${aws_iam_role.cp_build_LambdaExecution.id}"
}

output "codebuild_watcher_rule_arn" {
  value = "${aws_cloudwatch_event_rule.codebuild_watcher_rule.arn}"
}
