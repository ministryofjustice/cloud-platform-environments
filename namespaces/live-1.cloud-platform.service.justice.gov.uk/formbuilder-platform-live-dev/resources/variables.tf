# auto-generated from fb-cloud-platforms-environments
variable "environment-name" {
  default = "live-dev"
}

variable "team_name" {
  default = "formbuilder"
}

variable "db_backup_retention_period_submitter" {
  default = "2"
}

variable "db_backup_retention_period_user_datastore" {
  default = "2"
}

variable "is-production" {
  default = "true"
}

variable "infrastructure-support" {
  default = "Form Builder form-builder-team@digital.justice.gov.uk"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "namespace" {
  default = "formbuilder-platform-live-dev"
}
