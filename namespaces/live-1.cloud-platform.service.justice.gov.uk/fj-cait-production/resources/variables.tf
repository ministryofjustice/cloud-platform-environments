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
  default = "Get help with child arrangements"
}

variable "namespace" {
  default = "fj-cait-production"
}

variable "business-unit" {
  default = "Family Justice"
}

variable "repo_name" {
  default = "pflr-cait"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
