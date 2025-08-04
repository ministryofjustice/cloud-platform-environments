variable "queue_name" {
  type        = string
  description = "SQS Queue Name"
}

variable "sqs_queue_subscriber_applications" {
  type        = list(string)
  description = "List of applications that need to subscribe to the SQS queue, the names provided here must match the application tag on the applications' IRSA service accounts"
}

variable "sqs_subscriber_roles_regex_filter" {
  type        = string
  description = "regex to filter IRSA accounts from all IAM roles in the CP"
  default     = "^cloud-platform-irsa.*" #--This has a 1000 response limit
}

variable "fifo_queue" {
  type        = bool
  description = "FIFO SQS Queue"
  default     = false
}

variable "encrypted_queue" {
  type        = bool
  description = "Encrypt SQS Queue using KMS"
  default     = false
}

variable "dlq_max_receive_count" {
  type        = number
  description = "DLQ Max Receive Count"
  default     = 3
}

/* CP Dependency Variables. Must be passed directly from calling CP environment
I.E. business_unit = var.business_unit */
variable "business_unit" {
  type = string
}

variable "application" {
  type = string
}

variable "is_production" {
  type = string
}

variable "team_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "infrastructure_support" {
  type = string
}
