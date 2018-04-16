variable "create_sns_topic" {
  description = "Whether to create new SNS topic"
  default     = true
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to create"
  default     = "notify_slack"
}

variable "sns_topic_name" {
  description = "The name of the SNS topic to create"
  default     = "cp-build-notifications"
}

variable "slack_webhook_url" {
  description = "The URL of Slack webhook"
  default     = "https://hooks.slack.com/services/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"
}

variable "slack_channel" {
  description = "The name of the channel in Slack for notifications"
  default     = "cp-build-notification"
}

variable "slack_username" {
  description = "The username that will appear on Slack on messages"
  default     = "build-status"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for decrypting slack webhook url"
  default     = ""
}
