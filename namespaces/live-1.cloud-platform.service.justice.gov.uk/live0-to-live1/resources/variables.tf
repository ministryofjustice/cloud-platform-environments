variable "environment-name" {
  default = "live1-dev"
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
  default = "eu-west-2"
}

variable "business_unit" {
  default = "cp-live1"
}

variable "application" {
  default = "app-live1"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
