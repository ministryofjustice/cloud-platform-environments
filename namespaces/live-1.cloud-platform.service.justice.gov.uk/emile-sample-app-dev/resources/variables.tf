variable "team_name" {
  default = "formbuilder-dev"
}

variable "is-production" {
  default = "false"
}

variable "namespace" {
  default = "emile-sample-app-dev"
}

variable "repo_name" {
  default = "emile-sample-app"
}

variable "application" {
  default = "emile-sample-app"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "environment-name" {
  default = "staging"
}

variable "business-unit" {
  default = "MOJ Digital"
}

variable "infrastructure-support" {
  default = "Form Builder form-builder-team@digital.justice.gov.uk"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
