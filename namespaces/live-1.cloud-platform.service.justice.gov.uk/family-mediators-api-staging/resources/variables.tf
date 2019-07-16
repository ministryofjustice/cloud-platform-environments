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
  default = "Family Mediators API"
}

variable "namespace" {
  default = "family-mediators-api-staging"
}

variable "repo_name" {
  default = "family-mediators-api"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
