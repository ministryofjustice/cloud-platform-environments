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
  default = "pecs-move-platform-backend-staging"
}

variable "repo_name" {
  default = "pecs-move-platform-backend"
}

variable "aws_region" {
  default = "eu-west-2"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
