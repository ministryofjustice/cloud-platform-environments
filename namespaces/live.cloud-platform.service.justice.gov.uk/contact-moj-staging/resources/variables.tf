/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "contact-moj-staging"
}

variable "domain" {
  default = "staging.contact-moj.service.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "environment" {
  default = "staging"
}

variable "infrastructure_support" {
  default = "correspondence@digital.justice.gov.uk"
}
