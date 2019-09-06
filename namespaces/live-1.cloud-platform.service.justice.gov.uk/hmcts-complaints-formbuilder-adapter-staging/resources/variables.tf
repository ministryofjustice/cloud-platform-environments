variable "team_name" {
  description = "The name of your development team"
  default     = "form-builder"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}

variable "db_backup_retention_period_hmcts_complaints_adapter" {
  default = "2"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "Form Builder form-builder-team@digital.justice.gov.uk"
}
