/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {
}


variable "namespace" {
  default = "track-a-query-production"
}

variable "domain" {
  default = "track-a-query.service.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}

variable "application" {
  default = "track-a-query"
}

variable "infrastructure-support" {
  default = "correspondence-support@digital.justice.gov.uk"
}

variable "team_name" {
  default = "correspondence"
}

