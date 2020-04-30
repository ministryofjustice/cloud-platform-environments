variable "application" {
  description = "Application name"
  default     = "crimeapps"
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
  default     = "uat"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "crimeapps-laa@digital.justice.gov.uk"
}

variable "namespace" {
  description = "The kubernetes namespace within the resource will be created."
  default     = "laa-court-data-adaptor-uat"
}

variable "is_production" {
  default = "false"
}

variable "encrypt_sqs_kms" {
  description = "Encrypt sqs keys."
  default     = "false"
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)."
  default     = "1209600"
}


