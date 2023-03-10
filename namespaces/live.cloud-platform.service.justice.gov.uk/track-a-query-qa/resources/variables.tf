/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}


variable "namespace" {
  default = "track-a-query-qa"
}

variable "domain" {
  default = "qa.track-a-query.service.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "environment" {
  default = "qa"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "correspondence@digital.justice.gov.uk"
}

