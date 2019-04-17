variable "environment-name" {
  default = "live0-dev"
}

variable "team_name" {
  default = "team-webops"
}

variable "is-production" {
  default = "false"
}

variable "namespace" {
  default = "live0-to-live1"
}

variable "infrastructure-support" {
  default = "webops@digtal.justice.gov.uk"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "business_unit" {
  default = "cp-live0"
}

variable "application" {
  default = "app-live0"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
