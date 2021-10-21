/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}

variable "namespace" {
  default = "peoplefinder-production"
}

variable "domain" {
  default = "peoplefinder.service.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}

variable "application" {
  default = "peoplefinder"
}

variable "infrastructure-support" {
  default = "people-finder-support@digital.justice.gov.uk"
}

variable "team_name" {
  default = "peoplefinder"
}
