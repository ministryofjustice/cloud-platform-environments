/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "environment-name" {
  default = "production"
}

variable "team_name" {
  default = "prison-visits-booking"
}

variable "is_production" {
  default = "true"
}

variable "namespace" {
  default = "prison-visits-booking-production"
}

variable "infrastructure_support" {
  default = "pvb-technical-support@digital.justice.gov.uk"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}
