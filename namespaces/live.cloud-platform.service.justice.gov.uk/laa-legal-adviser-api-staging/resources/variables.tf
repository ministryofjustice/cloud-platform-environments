/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "namespace" {
  default = "laa-legal-adviser-api-staging"
}

variable "business_unit" {
  default = "LAA"
}

variable "team_name" {
  default = "laa-get-access"
}

variable "application" {
  default = "LAA-Legal-Adviser-API"
}

variable "repo_name" {
  default = "laa-legal-adviser-api"
}

variable "email" {
  default = "laa-get-access@digital.justice.gov.uk"
}

variable "environment-name" {
  default = "staging"
}

variable "is_production" {
  default = "false"
}

