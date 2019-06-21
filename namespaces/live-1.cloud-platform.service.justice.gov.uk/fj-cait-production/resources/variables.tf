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

variable "domain" {
  default = "https://helpwithchildarrangements.service.justice.gov.uk"
}

variable "business-unit" {
  default = "c100"
}

variable "repo_name" {
  default = "pflr-cait"
}

variable "aws_region" {
  default = "eu-west-2"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}
