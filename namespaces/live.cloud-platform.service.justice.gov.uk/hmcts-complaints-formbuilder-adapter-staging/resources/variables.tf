variable "team_name" {
  description = "The name of your development team"
  default     = "form-builder"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}


variable "db_backup_retention_period_hmcts_complaints_adapter" {
  default = "2"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "Form Builder form-builder-team@digital.justice.gov.uk"
}

variable "namespace" {
  default = "hmcts-complaints-formbuilder-adapter-staging"
}
