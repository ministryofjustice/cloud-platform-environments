variable "team_name" {
  default = "pecs"
}

variable "environment-name" {
  default = "production"
}

variable "is-production" {
  default = "true"
}

variable "infrastructure-support" {
  default = "PECS: pecs-team@digital.justice.gov.uk"
}

variable "application" {
  default = "PECS move platform backend"
}

variable "namespace" {
  default = "hmpps-book-secure-move-api-production"
}

variable "repo_name" {
  default = "hmpps-book-secure-move-api"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
