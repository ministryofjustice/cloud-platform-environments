/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "environment" {
  default = "staging"
}

variable "team_name" {
  default = "offender-management"
}

variable "is_production" {
  default = "false"
}

variable "namespace" {
  default = "hmpps-complexity-of-need-staging"
}

variable "infrastructure_support" {
  default = "manage-pom-cases@digital.justice.gov.uk"
}
