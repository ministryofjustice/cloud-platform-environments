variable "team_name" {
  default = "family-justice"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "environment-name" {
  default = "staging"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "Family Justice: family-justice-team@digital.justice.gov.uk"
}

variable "application" {
  default = "Get help with child arrangements"
}

variable "namespace" {
  default = "fj-cait-staging"
}

variable "repo_name" {
  default = "pflr-cait"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
