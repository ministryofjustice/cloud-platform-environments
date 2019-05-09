variable "environment-name" {
  default = "staging"
}

variable "team_name" {
  default = "prison-visits-booking"
}

variable "is-production" {
  default = "false"
}

variable "namespace" {
  default = "prison-visits-booking-staging"
}

variable "infrastructure-support" {
  default = "pvb-technical-support@digtal.justice.gov.uk"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
