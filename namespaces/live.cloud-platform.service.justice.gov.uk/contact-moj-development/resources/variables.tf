/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "contact-moj-development"
}

variable "domain" {
  default = "development.contact-moj.service.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "environment" {
  default = "development"
}

variable "infrastructure_support" {
  default = "correspondence@digital.justice.gov.uk"
}
