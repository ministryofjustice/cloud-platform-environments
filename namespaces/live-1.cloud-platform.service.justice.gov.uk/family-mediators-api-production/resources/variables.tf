variable "team_name" {
  default = "family-justice"
}

variable "environment-name" {
  default = "production"
}

variable "is-production" {
  default = "true"
}

variable "infrastructure-support" {
  default = "Family Justice: family-justice-team@digital.justice.gov.uk"
}

variable "application" {
  default = "Family Mediators API"
}

variable "namespace" {
  default = "family-mediators-api-production"
}

variable "repo_name" {
  default = "family-mediators-api"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
