# auto-generated from fb-cloud-platforms-environments

variable "application" {
  default = "multi-container-demo"
}

variable "namespace" {
  default = "davids-dummy-dev"
}

variable "environment-name" {
  default = "dev"
}

variable "team_name" {
  default = "davids-dummy-dev"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "David Salgado david.salgado@digital.justice.gov.uk"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
