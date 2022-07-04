variable "application" {
  description = "Application name"
  default     = "LAA Court Data Adaptor"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "mojdigital"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "crime-apps"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "crimeapps-laa@digital.justice.gov.uk"
}

variable "namespace" {
  description = "The kubernetes namespace within the resource will be created."
  default     = "laa-court-data-adaptor-prod"
}

variable "is_production" {
  default = "true"
}

variable "encrypt_sqs_kms" {
  description = "Encrypt sqs keys."
  default     = "false"
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)."
  default     = "1209600"
}

variable "domain" {
  default = "court-data-adaptor.service.justice.gov.uk"
}
variable "visibility_timeout_seconds" {
  description = "Sets the length of time (seconds) that a message received from a queue will not be visible to the other message consumers."
  default     = "120"
}

data "aws_caller_identity" "current" {}

variable "account_id" {
  description = "AWS Account ID"
  default = data.aws_caller_identity.current.account_id
}
