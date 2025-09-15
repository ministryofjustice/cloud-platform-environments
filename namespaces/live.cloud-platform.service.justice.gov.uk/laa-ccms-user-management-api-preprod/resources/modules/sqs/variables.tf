variable "queue_name" {
  type        = string
  description = "SQS Queue Name"
}

variable "sqs_queue_subscriber_namespaces" {
  type        = list(string)
  description = "List of namespaces that need to subscribe to the SQS queue, the names provided here must match the namespace tag on the namespace' IRSA service accounts. This list does not need to contain the namespace that the module is being deployed to, which is implicitly granted access"
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

variable "visibility_timeout_seconds" {
  type        = number
  description = "The visibility timeout for the queue. An integer from 0 to 43200"
  default     = 30
}

variable "delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900"
  default     = 0
}

variable "message_retention_seconds" {
  type        = number
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)"
  default     = 345600
}

variable "max_message_size" {
  type        = number
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB)."
  default     = 262144
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
