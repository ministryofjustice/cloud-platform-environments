/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}


variable "namespace" {
  default = "track-a-query-development"
}

variable "domain" {
  default = "development.track-a-query.service.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "environment" {
  default = "development"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "correspondence@digital.justice.gov.uk"
}

variable "team_name" {
  default = "correspondence"
}

variable "business_unit" {
  default = "Central Digital"
}

variable "application" {
  default = "track-a-query"
}
