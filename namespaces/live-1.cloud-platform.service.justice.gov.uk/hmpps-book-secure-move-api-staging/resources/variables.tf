variable "team_name" {
  default = "pecs"
}

variable "environment-name" {
  default = "staging"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "PECS: pecs-team@digital.justice.gov.uk"
}

variable "application" {
  default = "PECS move platform backend"
}

variable "namespace" {
  default = "hmpps-book-secure-move-api-staging"
}

variable "repo_name" {
  default = "hmpps-book-secure-move-api"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "aws_alias" {
  default = "london"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
