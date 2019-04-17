# auto-generated from fb-cloud-platforms-environments
variable "environment-name" {
  default = "integration"
}

variable "team_name" {
  default = "formbuilder"
}

variable "is-production" {
  default = "false"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "infrastructure-support" {
  default = "Form Builder form-builder-team@digital.justice.gov.uk"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
