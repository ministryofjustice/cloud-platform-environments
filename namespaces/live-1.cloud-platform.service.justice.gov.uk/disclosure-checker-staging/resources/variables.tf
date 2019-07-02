variable "team_name" {
  default = "family-justice"
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
  default = "Disclosure Checker"
}

variable "namespace" {
  default = "disclosure-checker-staging"
}

variable "repo_name" {
  default = "disclosure-checker"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
