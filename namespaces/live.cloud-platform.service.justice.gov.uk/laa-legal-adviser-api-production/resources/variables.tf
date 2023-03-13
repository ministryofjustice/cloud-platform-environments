/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "namespace" {
  default = "laa-legal-adviser-api-production"
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

variable "email" {
  default = "laa-get-access@digital.justice.gov.uk"
}

variable "environment-name" {
  default = "production"
}

variable "is_production" {
  default = "true"
}

