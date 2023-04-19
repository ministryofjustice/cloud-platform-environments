/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "environment_name" {
  default = "preprod"
}

variable "team_name" {
  default = "offender-management"
}

variable "application" {
  default = "offender-management-allocation-manager"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "is_production" {
  default = "true"
}

variable "namespace" {
  default = "offender-management-preprod"
}

variable "infrastructure_support" {
  default = "manage-pom-cases@digital.justice.gov.uk"
}
